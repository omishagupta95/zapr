#!/bin/bash	
set -x

delete_template() {
	gcloud compute instance-templates delete $1 -q
}

delete_instance_group() {
	gcloud compute instance-groups managed delete $1 --region=asia-south1 -q
}

delete_backend_service() {
	gcloud compute backend-services delete $1 --global -q
}

delete_path_matcher() {
  gcloud compute url-maps remove-path-matcher $1-http-lb --path-matcher-name path-matcher-1 -q 
}

attach_dummy_backend() {
  gcloud compute backend-services add-backend $1 --instance-group=hot-cluster-unmanaged-instance-group --instance-group-region=asia-south1 --global -q
}

main(){
for ((i=1; i<=$1; i++)); do
	attach_dummy_backend test-backend 
	delete_backend_service $2-backend-$i
	delete_instance_group $2-group-$i
    	delete_template $2-temp-$i
    done
}

read -p "which resources you want deprovision, hot or cold (case sensitive)" type
read -p "Enter the number of templates you want to delete: " count
delete_path_matcher $type
main $count $type

