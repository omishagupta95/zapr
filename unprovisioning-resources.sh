#!/bin/bash	
set -x

delete_template() {
	gcloud compute instance-templates delete $1
}

delete_instance_group() {
	gcloud compute instance-groups managed delete $1 --region=asia-south1
}

delete_backend_service() {
	gcloud compute backend-services delete $1 --global
}

delete_path_matcher() {
  gcloud compute url-maps remove-path-matcher test-http-lb --path-matcher-name path-matcher-1
}

attach_dummy_backend() {
  gcloud compute backend-services add-backend $1 --instance-group=$2 --instance-group-region=us-east1 --global
}

main(){
for ((i=1; i<=$1; i++)); do
	attach_dummy_backend mukesh-test-backend mukesh-test-instance-group-tomcat
	delete_path_matcher
	delete_backend_service hot-backend-$i
	delete_instance_group hot-group-$i
    delete_template hot-temp-$i
    done
}

read -p "Enter the number of templates you want to delete: " count
main $count
