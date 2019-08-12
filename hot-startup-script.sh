#!/bin/bash
set -x
get_data() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    gsutil -m cp gs://zapr_bucket/hotcluster/$metadata/hotcluster.txt /opt/kyoto/hotcluster.txt
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/hotcluster/$metadata/matcher.kch  /opt/kyoto/matcher.kch
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/hotcluster/$metadata/prefilter.kch  /opt/kyoto/prefilter.kch
}

update_tar() {
       sudo supervisorctl stop all
       #Clear all the older artifacts
       rm -rf /opt/kyoto/*
       sudo rm -rf /etc/supervisor/conf.d/*
       rm -rf /opt/zapr/prod-active-song-revealer/
       src_tar_location=gs://zapr_bucket/tarballs/hot_ubuntu_auto_deploy.tar.gz
       sudo mkdir /opt/temp
       temp_tar_download_location=/opt/temp/
       dest_location=/opt/zapr/
       gsutil cp $src_tar_location $temp_tar_download_location
       cd $temp_tar_download_location
       tar -xzvf hot_ubuntu_auto_deploy.tar.gz -C /opt/zapr/
       sudo sed -i "s|ue-adtech-graphite-1.zapr.com|172.16.15.226|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
}

update_nginx() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    sudo sed -i "s|^    location .*$|    location /hotcluster/${metadata}|" /etc/nginx/sites-enabled/default   
    sudo sed -i "s|^            rewrite .*$|            rewrite ^/hotcluster/${metadata}/(.*) /\$1 break;|" /etc/nginx/sites-enabled/default
    sudo service nginx restart
}    

main() {
    update_tar
    sudo mount -t tmpfs -o size=35G tmpfs /opt/kyoto
    /opt/zapr/prod-active-song-revealer/scripts/kyotoFix.sh
    get_data
    mkdir -p /opt/zapr/prod-active-song-revealer/logs
    sed -i '/  - name: get ec2 facts/,/var=out/d' /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml
    ansible-playbook /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml | tee /opt/zapr/prod-active-song-revealer/logs/deploy.log
    ansible-playbook /opt/zapr/prod-active-song-revealer/scripts/nginx/nginx_hot.yml
    update_nginx
}
main
