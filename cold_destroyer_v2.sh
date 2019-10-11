#!/bin/bash
set -x

delete_template() {
        gcloud compute instance-templates delete $1 --quiet
}

delete_instance_group(){

     if [[ $2 -eq 1 ]] || [[ $2 -eq 13 ]] || [[ $2 -eq 14 ]] || [[ $2 -eq 17 ]] || [[ $2 -eq 18 ]] || [[ $2 -eq 19 ]] || [[ $2 -eq 20 ]] || [[ $2 -eq 23 ]] || [[ $2 -eq 25 ]] || [[ $2 -eq 26 ]] || [[ $2 -eq 27 ]] || [[ $2 -eq 3 ]] || [[ $2 -eq 32 ]] || [[ $2 -eq 33 ]] || [[ $2 -eq 34 ]] || [[ $2 -eq 35 ]] || [[ $2 -eq 36 ]] || [[ $2 -eq 37 ]] || [[ $2 -eq 38 ]] || [[ $2 -eq 45 ]] || [[ $2 -eq 47 ]] || [[ $2 -eq 48 ]] || [[ $2 -eq 54 ]] || [[ $2 -eq 55 ]] || [[ $2 -eq 62 ]] || [[ $2 -eq 64 ]] || [[ $2 -eq 68 ]] || [[ $2 -eq 73 ]] || [[ $2 -eq 74 ]] || [[ $2 -eq 83 ]] || [[ $2 -eq 88 ]] || [[ $2 -eq 90 ]] || [[ $2 -eq 92 ]] || [[ $2 -eq 93 ]] || [[ $2 -eq 97 ]] || [[ $2 -eq 99 ]] || [[ $2 -eq 101 ]]
     then
     	gcloud compute instance-groups managed delete $1 --zone=asia-south1-b --quiet
     elif [[ $2 -eq 2 ]] || [[ $2 -eq 4 ]] || [[ $2 -eq 5 ]] || [[ $2 -eq 7 ]] || [[ $2 -eq 8 ]] || [[ $2 -eq 9 ]] || [[ $2 -eq 11 ]] || [[ $2 -eq 15 ]] || [[ $2 -eq 12 ]] || [[ $2 -eq 22 ]] || [[ $2 -eq 24 ]] || [[ $2 -eq 29 ]] || [[ $2 -eq 30 ]] || [[ $2 -eq 39 ]] || [[ $2 -eq 40 ]] || [[ $2 -eq 41 ]] || [[ $2 -eq 43 ]] || [[ $2 -eq 44 ]] || [[ $2 -eq 51 ]] || [[ $2 -eq 52 ]] || [[ $2 -eq 53 ]] || [[ $2 -eq 56 ]] || [[ $2 -eq 63 ]] || [[ $2 -eq 65 ]] || [[ $2 -eq 66 ]] || [[ $2 -eq 67 ]] || [[ $2 -eq 69 ]] || [[ $2 -eq 72 ]] || [[ $2 -eq 75 ]] || [[ $2 -eq 78 ]] || [[ $2 -eq 80 ]] || [[ $2 -eq 81 ]] || [[ $2 -eq 82 ]] || [[ $2 -eq 86 ]] || [[ $2 -eq 89 ]] || [[ $2 -eq 94 ]] || [[ $2 -eq 96 ]] || [[ $2 -eq 102 ]]
     then
        gcloud compute instance-groups managed delete $1 --zone=asia-south1-a --quiet
     elif [[ $2 -eq 6 ]] || [[ $2 -eq 10 ]] || [[ $2 -eq 12 ]] || [[ $2 -eq 16 ]] || [[ $2 -eq 21 ]] || [[ $2 -eq 28 ]] || [[ $2 -eq 31 ]] || [[ $2 -eq 42 ]] || [[ $2 -eq 46 ]] || [[ $2 -eq 49 ]] || [[ $2 -eq 50 ]] || [[ $2 -eq 57 ]] || [[ $2 -eq 58 ]] || [[ $2 -eq 59 ]] || [[ $2 -eq 60 ]] || [[ $2 -eq 61 ]] || [[ $2 -eq 70 ]] || [[ $2 -eq 71 ]] || [[ $2 -eq 76 ]] || [[ $2 -eq 77 ]] || [[ $2 -eq 79 ]] || [[ $2 -eq 84 ]] || [[ $2 -eq 85 ]] || [[ $2 -eq 87 ]] || [[ $2 -eq 91 ]] || [[ $2 -eq 95 ]] || [[ $2 -eq 98 ]] || [[ $2 -eq 100 ]] || [[ $2 -eq 103 ]]
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

main(){
        create_path_rules 
        for ((i=103; i>=0; i--)); do
        delete_backend_service cold-backend-$i
        delete_instance_group cold-group-$i $i
        delete_template cold-temp-$i
        done
}

main 
