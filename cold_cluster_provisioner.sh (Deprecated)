#!/bin/bash	
set -x

create_template() {
	gcloud compute instance-templates create $1 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v13" --boot-disk-type="pd-ssd" --boot-disk-size="50" --local-ssd interface=NVMe --local-ssd interface=NVMe --local-ssd interface=NVMe --local-ssd interface=NVMe --network="zapr-vpc-network" --subnet="private-1" --tags="allow-ssh" --preemptible --metadata-from-file startup-script="./cold-startup-script.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=$2 --region=asia-south1
}

create_instance_group(){
	gcloud compute instance-groups managed create $1 --size=1 --template=$2 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc --initial-delay 2700
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
    s+=/coldcluster/$i/*=cold-backend-$i,
  done
  s=${s%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}



main(){
	for ((i=1; i<=$1; i++)); do
        create_template cold-temp-$i $i
        create_instance_group cold-group-$i cold-temp-$i
        create_backend_service cold-backend-$i
        attach_backend cold-backend-$i cold-group-$i
    done   
}

read -p "Enter the number of templates you want to create: " count
main $count
create_path_rules $count
