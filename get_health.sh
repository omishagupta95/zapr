echo "HEALTH OF COLD VMs\n"
for ((i=1; i<=103; i++)); do 
    gcloud compute backend-services get-health cold-backend-$i --global --filter unhealthy
  done

echo "\nHEALTH OF HOT VMs"
for ((i=1; i<=11; i++)); do 
    gcloud compute backend-services get-health hot-backend-$i --global --filter unhealthy
  done
