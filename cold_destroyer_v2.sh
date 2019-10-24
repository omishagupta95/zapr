#!/bin/bash
set -x

delete_template() {
        gcloud compute instance-templates delete $1 --quiet
}

delete_instance_group(){

     if (( $i % 3 == 1 ))
     then
     	gcloud compute instance-groups managed delete $1 --zone=asia-south1-a --quiet
     elif (( $i % 3 == 2 ))
     then
        gcloud compute instance-groups managed delete $1 --zone=asia-south1-b --quiet
     elif (( $i % 3 == 0 ))
     then
        gcloud compute instance-groups managed delete $1 --zone=asia-south1-c --quiet
     fi
}

delete_backend_service() {
        gcloud compute backend-services delete $1 --global --quiet
}

create_path_rules() {
  gcloud compute url-maps remove-path-matcher cold-http-lb --path-matcher-name path-matcher-1 -q
  gcloud compute url-maps remove-path-matcher cold-http-lb-2 --path-matcher-name path-matcher-1 -q
  gcloud compute url-maps remove-path-matcher cold-http-lb-3 --path-matcher-name path-matcher-1 -q
  
  s=""
  s+=*=test-backend
  gcloud compute url-maps add-path-matcher cold-http-lb --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher

  gcloud compute url-maps add-path-matcher cold-http-lb-2 --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher

  gcloud compute url-maps add-path-matcher cold-http-lb-3 --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-path-matcher
}

execute(){
  delete_backend_service cold-backend-$1
  delete_instance_group cold-group-$1 $1
  delete_template cold-temp-$1
}

main() {
  create_path_rules
    for ((i=$1; i>=$2; i--)); do
      execute $i &
    done
    exit
}

read -p "upper limit: " count
read -p "lower limit: " limit
main $count $limit 
