#!/bin/bash
set -x

delete_template() {
        gcloud compute instance-templates delete $1 --quiet
}
delete_instance_group(){
        gcloud compute instance-groups managed delete $1 --region=asia-south1 --quiet
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

main(){
        create_path_rules 
        for ((i=103; i>=0; i--)); do
        delete_backend_service cold-backend-$i
        delete_instance_group cold-group-$i
        delete_template cold-temp-$i
        done
}

main 
