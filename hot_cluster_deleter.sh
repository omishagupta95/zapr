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
  gcloud compute url-maps remove-path-matcher hot-http-lb --path-matcher-name path-matcher-1 -q
  s=""
  if [ $1 -eq 0 ]
  then
    s+=*=test-backend
    gcloud compute url-maps add-path-matcher hot-http-lb --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-
path-matcher
  else
    for ((i=1;i<=$1;i++)); do
      s+=/hotcluster/$i/*=hot-backend-$i,
    done
    gcloud compute url-maps add-path-matcher hot-http-lb --default-service test-backend --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphaned-
path-matcher
    s=${s%?};
  fi
}
main(){
        create_path_rules $2
        for ((i=$1; i>$2; i--)); do
        delete_backend_service hot-backend-$i
        delete_instance_group hot-group-$i
        delete_template hot-temp-$i
        done
}
read -p "This script is for deletion of hot instance groups. If you have 3 IGs, and you want to scale down to 0. Set start value as 3, and end value as 0. Please enter the s
tart value: " start
read -p "Enter the total number of hot instance groups you want to scale down to, i.e, the end value: " end
main $start $end
