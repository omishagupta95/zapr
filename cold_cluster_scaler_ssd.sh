#!/bin/bash
set -x

create_template() {
        gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v16" --boot-disk-type="pd-ssd" --boot-disk-size="50" --create-disk=mode=rw,size=500,type=pd-ssd,name=cold-disk-$i,device-name=persistent-disk-$1 --network="zapr-vpc-network" --subnet="private-1" --tags="allow-ssh" $3 --metadata-from-file startup-script="./cold-startup-script.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=$2 --region=asia-south1
#        --disk=name=cold-disk-$i  use this instead of create-disk flag once all disks have been created
}

create_instance_group(){
if [ $3 -lt 35 ]
then
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc --initial-delay 2700
elif [[ $3 -ge 35 ]] && [[ $3 -lt 85 ]]
then  
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc-1 --initial-delay 2700
elif [[ $3 -ge 85 ]] && [[ $3 -lt 135 ]]
then
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc-2 --initial-delay 2700
elif [[$3 -ge 135 ] && [ $3 -lt 185 ]]
then 
     gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc-3 --initial-delay 2700
fi
}

create_backend_service(){
if [ $2 -lt 35 ]
then
     gcloud compute backend-services create $1 --health-checks=router-hc --port-name=http --protocol=HTTP --global
elif [[ $2 -ge 35 ]] && [[ $3 -lt 85 ]]
then  
     gcloud compute backend-services create $1 --health-checks=router-hc-1 --port-name=http --protocol=HTTP --global
elif [[ $2 -ge 85 ]] && [[ $3 -lt 135 ]]
then
     gcloud compute backend-services create $1 --health-checks=router-hc-2 --port-name=http --protocol=HTTP --global
elif [[ $2 -ge 135 ]] && [[ $3 -lt 185 ]]
then 
     gcloud compute backend-services create $1 --health-checks=router-hc-3 --port-name=http --protocol=HTTP --global
fi
}

attach_backend() {
        gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-region=asia-south1 --global
        gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1

}

create_path_rules() {
  gcloud compute url-maps remove-path-matcher cold-http-lb --path-matcher-name path-matcher-1 -q
  s=""
  for ((i=1;i<=$1;i++)); do
    s+=/coldcluster/$i/*=cold-backend-$i,
  done
  s=${s%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb --default-service cold-backend-1 --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}

main(){
        for ((i=$1; i<=$2; i++)); do
        create_template cold-temp-$i $i $3
        create_instance_group cold-group-$i cold-temp-$i $i
        create_backend_service cold-backend-$i $i
        attach_backend cold-backend-$i cold-group-$i
    done
}
read -p "This script is for scaling of cold instance groups. If you have 3 IGs, and you want to scale up to 10. Set start value as 4, and end value as 10. Please enter the start value: " start
read -p "Enter the total number of cold instance groups you want to create, i.e, the end value: " end
read -p "Choose preemptible(--preemptible) or non-preemptible(press spacebar and enter){case sensitive}" type
main $start $end $type
if [ $end -lt 50 ]
then
   create_path_rules $end
else 
   bash ./path_manual.sh
fi
