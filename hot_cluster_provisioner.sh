#!/bin/bash	
set -x

create_template() {
	gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="hot-cluster-instance-image-v5" --boot-disk-type="pd-ssd" --boot-disk-size="30" --network="zapr-vpc-network" --subnet="private-1" --tags="allow-ssh" --preemptible --metadata-from-file startup-script="./hot-startup-script.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=$2 --region=asia-south1
}

create_instance_group(){
	gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=hot-instance --region=asia-south1 --health-check=router-hc --initial-delay 2700
}

create_backend_service(){
	gcloud compute backend-services create $1 --health-checks=router-hc --port-name=http --protocol=HTTP --global
}

attach_backend() {
	gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-region=asia-south1 --global
	gcloud compute instance-groups managed set-named-ports $2 --named-ports "http:80" --region=asia-south1

}

create_path_rules() {
  s=""
  for ((i=1;i<=$1;i++)); do
     s+=/hotcluster/$i/*=hot-backend-$i,
  done
  s=${s%?};
  gcloud compute url-maps add-path-matcher hot-http-lb --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}

main(){
	for ((i=1; i<=$1; i++)); do
        create_template hot-temp-$i $i
        create_instance_group hot-group-$i hot-temp-$i
        create_backend_service hot-backend-$i
        attach_backend hot-backend-$i hot-group-$i
    done   
}

read -p "Enter the number of templates you want to create: " count
main $count
create_path_rules $count
