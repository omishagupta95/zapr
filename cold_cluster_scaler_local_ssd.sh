#!/bin/bash
set -x

# THIS SCRIPT IS FOR PROVISIONING COLD CLUSTER VMs with 1 local SSD
# THIS SCRIPT DOESN'T INTENDS TO CREATE LOAD BALANCER, IT ASSUMES THAT LOAD BALANCER WITH THE SIMILAR NAME ALREADY EXISTS

create_template_existing_disk() {
        gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v18" --boot-disk-type="pd-ssd" --boot-disk-size="50" --disk=name=cold-disk-00$i,mode=ro --network="zapr-vpc-network" --subnet="private-1" --tags="zapr-polestar-revealer" $3 --metadata-from-file startup-script="./cold-startup-script-existing-disk.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=$2 --region=asia-south1
#        --disk=name=cold-disk-$i  use this instead of create-disk flag once all disks have been created
}

create_template_new_disk() {
        gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v18" --boot-disk-type="pd-ssd" --boot-disk-size="50" --local-ssd interface=NVMe --network="zapr-vpc-network" --subnet="private-1" --tags="zapr-polestar-revealer" $3 --metadata-from-file startup-script="./cold_startup_script.sh",partition=$2  --scopes="monitoring,pubsub,storage-rw"  --region=asia-south1
#        --disk=name=cold-disk-$i  use this instead of create-disk flag once all disks have been created
}

create_instance_group() {
if [ $3 -lt 35 ]
  then
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=$4 --health-check=cold-healthcheck-1 --initial-delay=2700
elif [[ $3 -ge 35 ]] && [[ $3 -lt 85 ]]
  then  
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=$4 --health-check=cold-healthcheck-2 --initial-delay 2700
elif [[ $3 -ge 85 ]] && [[ $3 -lt 135 ]]
  then
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=$4 --health-check=cold-healthcheck-3 --initial-delay 2700
fi
}

create_backend_service(){
if [ $2 -lt 35 ]
then
     gcloud compute backend-services create $1 --health-checks=cold-healthcheck-1 --port-name=http --protocol=HTTP --global
elif [[ $2 -ge 35 ]] && [[ $2 -lt 85 ]]
then  
     gcloud compute backend-services create $1 --health-checks=cold-healthcheck-2 --port-name=http --protocol=HTTP --global
elif [[ $2 -ge 85 ]] && [[ $3 -lt 135 ]]
then
     gcloud compute backend-services create $1 --health-checks=cold-healthcheck-3 --port-name=http --protocol=HTTP --global
fi
}

attach_backend() {
    gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-zone=$3 --global
    gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --zone=$3
}

create_path_rules() {
  # gcloud compute url-maps remove-path-matcher cold-http-lb --path-matcher-name path-matcher-1 -q
  s=""
  for ((i=1;i<=$1;i++)); do
    s+=/coldcluster/$i/*=cold-backend-$i,
  done
  s=${s%?}; # To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb --default-service cold-backend-1 --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}

execute(){
      if [ "$option" == "true" ] || [ "$option" == "True" ]
      then
        echo "Caution: This creates new PD-SSD of size 500 gb"
        create_template_new_disk cold-temp-$1 $1 $2
      else
        echo "Caution: This attaches existing PD-SSD of size 500 gb"
        create_template_existing_disk cold-temp-$1 $1 $2
      fi
      if (( $1 % 3 == 1 ))
      then
        create_instance_group cold-group-$1 cold-temp-$1 $1 asia-south1-a
        create_backend_service cold-backend-$1 $1
        attach_backend cold-backend-$1 cold-group-$1 asia-south1-a
      elif (( $1 % 3 == 2 ))
      then
        create_instance_group cold-group-$1 cold-temp-$1 $1 asia-south1-b
        create_backend_service cold-backend-$1 $1
        attach_backend cold-backend-$1 cold-group-$1 asia-south1-b
      else (( $1 % 3 == 0 ))
        create_instance_group cold-group-$1 cold-temp-$1 $1 asia-south1-c
        create_backend_service cold-backend-$1 $1
        attach_backend cold-backend-$1 cold-group-$1 asia-south1-c
      fi     
}

main() {
  for ((i=$1; i<=$2; i++)); do 
    execute $i $type &
  done
}

read -p "This script is for scaling of cold instance groups. If you have 3 IGs, and you want to scale up to 10. Set start value as 4, and end value as 10. Please enter the start value: " start
read -p "Enter the total number of cold instance groups you want to create, i.e, the end value: " end
read -p "Choose preemptible(--preemptible) or non-preemptible(press spacebar and enter){case sensitive}: " type
read -p "Are the disks new? (True/False): " option
main $start $end
sleep 250s
if [ $end -lt 50 ]
then
   create_path_rules $end
else 
   bash ./path_manual.sh
fi
