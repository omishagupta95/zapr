#!/bin/bash
set -x

# THIS SCRIPT IS FOR RESIZING COLD MIGs TO 1 INSTANCE PER GROUP

resize_mig() {
    gcloud compute instance-groups managed resize $1 --size=1 --zone=$2 
}


execute(){
      if (( $1 % 3 == 1 ))
      then
        resize_mig cold-group-$1 asia-south1-a
      elif (( $1 % 3 == 2 ))
      then
        resize_mig cold-group-$1 asia-south1-b
      else (( $1 % 3 == 0 ))
        resize_mig cold-group-$1 asia-south1-c
      fi     
}

main() {
  for ((i=1; i<=$1; i++)); do 
    execute $i &
  done
}

read -p "This script is for resizing of cold instance groups. How many cold MIGs do you want to resize (to 1)?: " total
main $total


