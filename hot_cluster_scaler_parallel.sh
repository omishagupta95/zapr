#!/bin/bash
set -x

create_template() {
        gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="75" --custom-extensions --image="hot-cluster-instance-image-v6" --boot-disk-type="pd-ssd" --boot-disk-size="30" --network="zapr-vpc-network" --subnet="private-1" --tags="zapr-polestar-revealer" --preemptible --metadata startup-script-url="gs://zapr_bucket/startup-script/hot_startup.sh",partition=$2  --scopes="monitoring,pubsub,storage-rw" --region=asia-south1
}

create_instance_group(){
        gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=hot-instance --region=asia-south1 --health-check=hot-healthcheck-1 --initial-delay 2700
}

create_backend_service(){
        gcloud compute backend-services create $1 --health-checks=hot-healthcheck-1 --port-name=http --protocol=HTTP --global
}

attach_backend() {
        gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-region=asia-south1 --global
        gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1

}

create_path_rules() {
  gcloud compute url-maps remove-path-matcher hot-http-lb --path-matcher-name path-matcher-1 -q
  s=""
  for ((i=1;i<=$1;i++)); do
    s+=/hotcluster/$i/*=hot-backend-$i,
  done
  s=${s%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher hot-http-lb --default-service hot-backend-1 --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}

execute() {
        create_template hot-temp-$1 $1
        create_instance_group hot-group-$1 hot-temp-$1
        create_backend_service hot-backend-$1
        attach_backend hot-backend-$1 hot-group-$1
  }

main(){
      for ((i=$1; i<=$2; i++)); do
        execute $i &
        if [ $i == $2 ]
       then
         break
       else
        continue
       fi
      done
      sleep 250s
}

read -p "This script is for scaling of hot instance groups. If you have 3 IGs, and you want to scale up to 10. Set start value as 4, and end value as 10. Please enter the start value: " start
read -p "Enter the total number of hot instance groups you want to create, i.e, the end value: " end
# read -p "Choose preemptible(--preemptible) or non-preemptible(press spacebar and enter){case sensitive}" type
main $start $end
create_path_rules $end
