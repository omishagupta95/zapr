#!/bin/bash
set -x

get_data() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/Coldcluster/matcherreduced-$metadata.kch  /mnt/md0/matcher.kch
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/Coldcluster/prefilter-$metadata.kch /mnt/md0/prefilter.kch
}

copy_data() {
  /opt/zapr/prod-active-song-revealer/scripts/kyotoFix.sh
  .//root/script/md0.sh
  get_data
  mkdir -p /opt/zapr/prod-active-song-revealer/logs
  ansible-playbook /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml | tee /opt/zapr/prod-active-song-revealer/logs/deploy.log
}
copy_data
