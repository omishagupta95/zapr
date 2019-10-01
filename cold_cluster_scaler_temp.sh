#!/bin/bash
set -x

create_template() {
        gcloud compute instance-templates create cold-temp-01 --custom-cpu="8" --custom-memory="61" --custom-extensions --image="cold-cluster-instance-recreated-image-new-v13" --boot-disk-type="pd-ssd" --boot-disk-size="50" --local-ssd interface=NVMe --local-ssd interface=NVMe --local-ssd interface=NVMe --local-ssd interface=NVMe --network="zapr-vpc-network" --subnet="private-1" --tags="allow-ssh" 1 --metadata-from-file startup-script="./cold-startup-script-localssd.sh"  --scopes="monitoring,pubsub,storage-rw" --metadata partition=1 --region=asia-south1
}

create_instance_group(){
        gcloud compute instance-groups managed create cold-group-01 --size=1 --template=cold-temp-01 --base-instance-name=cold-instance --region=asia-south1 --health-check=router-hc-3 --initial-delay 2700
}


main(){
        create_template 
        create_instance_group
        }

main 
