#!/bin/bash
set -x
get_data() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    gsutil -m cp gs://zapr_bucket/hotcluster/$metadata/hotcluster.txt /opt/kyoto/hotcluster.txt
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/hotcluster/$metadata/matcher.kch  /opt/kyoto/matcher.kch
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/hotcluster/$metadata/prefilter.kch  /opt/kyoto/prefilter.kch
    sudo sed -i "s/metadata/$metadata/" /etc/nginx/sites-enabled/default
    sudo service nginx restart
}
main() {
    sudo mount -t tmpfs -o size=35G tmpfs /opt/kyoto
    /opt/zapr/prod-active-song-revealer/scripts/kyotoFix.sh
    get_data
    mkdir -p /opt/zapr/prod-active-song-revealer/logs
    ansible-playbook /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml | tee /opt/zapr/prod-active-song-revealer/logs/deploy.log
    ansible-playbook /opt/zapr/prod-active-song-revealer/scripts/nginx/nginx_hot.yml
    sudo service nginx reload
}
main
