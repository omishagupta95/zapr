#!/bin/bash
set -x

create_template() {
        gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v18" --boot-disk-type="pd-ssd" --boot-disk-size="50" --disk=name=cold-disk-$i --network="zapr-vpc-network" --subnet="private-1" --tags="allow-ssh" $3 --metadata-from-file startup-script="./cold-startup-script-existing-disk.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=$2 --region=asia-south1
#        --disk=name=cold-disk-$i  use this instead of create-disk flag once all disks have been created
}

create_instance_group(){
if [ $3 -lt 35 ]
then
     if [[ $3 -eq 1 ]] || [[ $3 -eq 13 ]] || [[ $3 -eq 14 ]] || [[ $3 -eq 17 ]] || [[ $3 -eq 18 ]] || [[ $3 -eq 19 ]] || [[ $3 -eq 20 ]] || [[ $3 -eq 23 ]] || [[ $3 -eq 25 ]] || [[ $3 -eq 26 ]] || [[ $3 -eq 27 ]] || [[ $3 -eq 3 ]] || [[ $3 -eq 32 ]] || [[ $3 -eq 33 ]] || [[ $3 -eq 34 ]]
     then
        gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-b --health-check=router-hc --initial-delay 2700
     elif [[ $3 -eq 2 ]] || [[ $3 -eq 4 ]] || [[ $3 -eq 5 ]] || [[ $3 -eq 7 ]] || [[ $3 -eq 8 ]] || [[ $3 -eq 9 ]] || [[ $3 -eq 11 ]] || [[ $3 -eq 15 ]] || [[ $3 -eq 12 ]] || [[ $3 -eq 24 ]] || [[ $3 -eq 29 ]] || [[ $3 -eq 30 ]] 
     then
        gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-a --health-check=router-hc --initial-delay 2700
     elif [[ $3 -eq 6 ]] || [[ $3 -eq 10 ]] || [[ $3 -eq 12 ]] || [[ $3 -eq 16 ]] || [[ $3 -eq 21 ]] || [[ $3 -eq 28 ]] || [[ $3 -eq 31 ]] 
     then
        gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-c --health-check=router-hc --initial-delay 2700
     fi
elif [[ $3 -ge 35 ]] && [[ $3 -lt 85 ]]
then  
     if [[ $3 -eq 39 ]] || [[ $3 -eq 40 ]] || [[ $3 -eq 41 ]] || [[ $3 -eq 43 ]] || [[ $3 -eq 44 ]] || [[ $3 -eq 51 ]] || [[ $3 -eq 52 ]] || [[ $3 -eq 53 ]] || [[ $3 -eq 56 ]] || [[ $3 -eq 63 ]] || [[ $3 -eq 65 ]] || [[ $3 -eq 66 ]] || [[ $3 -eq 67 ]] || [[ $3 -eq 69 ]] || [[ $3 -eq 72 ]] || [[ $3 -eq 75 ]] || [[ $3 -eq 78 ]] || [[ $3 -eq 80 ]] || [[ $3 -eq 81 ]] || [[ $3 -eq 82 ]]
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-a --health-check=router-hc-1 --initial-delay 2700
     elif [[ $3 -eq 35 ]] || [[ $3 -eq 36 ]] || [[ $3 -eq 37 ]] || [[ $3 -eq 38 ]] || [[ $3 -eq 45 ]] || [[ $3 -eq 47 ]] || [[ $3 -eq 48 ]] || [[ $3 -eq 54 ]] || [[ $3 -eq 55 ]] || [[ $3 -eq 62 ]] || [[ $3 -eq 64 ]] || [[ $3 -eq 68 ]] || [[ $3 -eq 73 ]] || [[ $3 -eq 74 ]] || [[ $3 -eq 83 ]]
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-b --health-check=router-hc-1 --initial-delay 2700  
     elif [[ $3 -eq 42 ]] || [[ $3 -eq 46 ]] || [[ $3 -eq 49 ]] || [[ $3 -eq 50 ]] || [[ $3 -eq 57 ]] || [[ $3 -eq 58 ]] || [[ $3 -eq 59 ]] || [[ $3 -eq 60 ]] || [[ $3 -eq 61 ]] || [[ $3 -eq 70 ]] || [[ $3 -eq 71 ]] || [[ $3 -eq 76 ]] || [[ $3 -eq 77 ]] || [[ $3 -eq 79 ]] || [[ $3 -eq 84 ]] 
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-c --health-check=router-hc-1 --initial-delay 2700
     fi
elif [[ $3 -ge 85 ]] && [[ $3 -lt 135 ]]
then
     if [[ $3 -eq 86 ]] || [[ $3 -eq 89 ]] || [[ $3 -eq 94 ]] || [[ $3 -eq 96 ]] || [[ $3 -eq 102 ]] 
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-a --health-check=router-hc-2 --initial-delay 2700
     elif [[ $3 -eq 88 ]] || [[ $3 -eq 90 ]] || [[ $3 -eq 92 ]] || [[ $3 -eq 93 ]] || [[ $3 -eq 97 ]] || [[ $3 -eq 99 ]] || [[ $3 -eq 101 ]] 
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-b --health-check=router-hc-2 --initial-delay 2700
     elif [[ $3 -eq 85 ]] || [[ $3 -eq 87 ]] || [[ $3 -eq 91 ]] || [[ $3 -eq 95 ]] || [[ $3 -eq 98 ]] || [[ $3 -eq 100 ]] || [[ $3 -eq 103 ]] 
     then
       gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --zone=asia-south1-c --health-check=router-hc-2 --initial-delay 2700
     fi
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
  if [[ $3 -eq 2 ]] || [[ $3 -eq 4 ]] || [[ $3 -eq 5 ]] || [[ $3 -eq 7 ]] || [[ $3 -eq 8 ]] || [[ $3 -eq 9 ]] || [[ $3 -eq 11 ]] || [[ $3 -eq 15 ]] || [[ $3 -eq 12 ]] || [[ $3 -eq 24 ]] || [[ $3 -eq 29 ]] || [[ $3 -eq 30 ]] || [[ $3 -eq 39 ]] || [[ $3 -eq 40 ]] || [[ $3 -eq 41 ]] || [[ $3 -eq 43 ]] || [[ $3 -eq 44 ]] || [[ $3 -eq 51 ]] || [[ $3 -eq 52 ]] || [[ $3 -eq 53 ]] || [[ $3 -eq 56 ]] || [[ $3 -eq 63 ]] || [[ $3 -eq 65 ]] || [[ $3 -eq 66 ]] || [[ $3 -eq 67 ]] || [[ $3 -eq 69 ]] || [[ $3 -eq 72 ]] || [[ $3 -eq 75 ]] || [[ $3 -eq 78 ]] || [[ $3 -eq 80 ]] || [[ $3 -eq 81 ]] || [[ $3 -eq 82 ]] || [[ $3 -eq 86 ]] || [[ $3 -eq 89 ]] || [[ $3 -eq 94 ]] || [[ $3 -eq 96 ]] || [[ $3 -eq 102 ]] 
  then
    gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-zone=asia-south1-a --global
    gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1 --zone=asia-south1-a
  elif [[ $3 -eq 1 ]] || [[ $3 -eq 13 ]] || [[ $3 -eq 14 ]] || [[ $3 -eq 17 ]] || [[ $3 -eq 18 ]] || [[ $3 -eq 19 ]] || [[ $3 -eq 20 ]] || [[ $3 -eq 23 ]] || [[ $3 -eq 25 ]] || [[ $3 -eq 26 ]] || [[ $3 -eq 27 ]] || [[ $3 -eq 3 ]] || [[ $3 -eq 32 ]] || [[ $3 -eq 33 ]] || [[ $3 -eq 34 ]] || [[ $3 -eq 35 ]] || [[ $3 -eq 36 ]] || [[ $3 -eq 37 ]] || [[ $3 -eq 38 ]] || [[ $3 -eq 45 ]] || [[ $3 -eq 47 ]] || [[ $3 -eq 48 ]] || [[ $3 -eq 54 ]] || [[ $3 -eq 55 ]] || [[ $3 -eq 62 ]] || [[ $3 -eq 64 ]] || [[ $3 -eq 68 ]] || [[ $3 -eq 73 ]] || [[ $3 -eq 74 ]] || [[ $3 -eq 83 ]] || [[ $3 -eq 88 ]] || [[ $3 -eq 90 ]] || [[ $3 -eq 92 ]] || [[ $3 -eq 93 ]] || [[ $3 -eq 97 ]] || [[ $3 -eq 99 ]] || [[ $3 -eq 101 ]] 
  then
    gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-zone=asia-south1-b --global
    gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1 --zone=asia-south1-b
  elif [[ $3 -eq 6 ]] || [[ $3 -eq 10 ]] || [[ $3 -eq 12 ]] || [[ $3 -eq 16 ]] || [[ $3 -eq 21 ]] || [[ $3 -eq 28 ]] || [[ $3 -eq 31 ]] || [[ $3 -eq 42 ]] || [[ $3 -eq 46 ]] || [[ $3 -eq 49 ]] || [[ $3 -eq 50 ]] || [[ $3 -eq 57 ]] || [[ $3 -eq 58 ]] || [[ $3 -eq 59 ]] || [[ $3 -eq 60 ]] || [[ $3 -eq 61 ]] || [[ $3 -eq 70 ]] || [[ $3 -eq 71 ]] || [[ $3 -eq 76 ]] || [[ $3 -eq 77 ]] || [[ $3 -eq 79 ]] || [[ $3 -eq 84 ]] || [[ $3 -eq 85 ]] || [[ $3 -eq 87 ]] || [[ $3 -eq 91 ]] || [[ $3 -eq 95 ]] || [[ $3 -eq 98 ]] || [[ $3 -eq 100 ]] || [[ $3 -eq 103 ]] 
  then
    gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-zone=asia-south1-c --global
    gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1 --zone=asia-south1-c
  fi
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
        attach_backend cold-backend-$i cold-group-$i $i
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
