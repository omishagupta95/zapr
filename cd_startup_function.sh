#!/bin/bash

main(){
       sudo supervisorctl stop all
       #Clear all the older artifacts
       rm -rf /opt/kyoto/*
       sudo rm -rf /etc/supervisor/conf.d/*
       rm -rf /opt/zapr/prod-active-song-revealer/
       src_tar_location=gs://zapr_bucket/tarballs/hot_ubuntu_auto_deploy.tar.gz
       temp_tar_download_location=/opt/temp/
       dest_location=/opt/zapr/
       aws s3 cp $src_tar_location $temp_tar_download_location
       cd $temp_tar_download_location
       tar -xzvf hot_ubuntu_auto_deploy.tar.gz -C /opt/zapr/
       cd  /opt/zapr/prod-active-song-revealer/scripts/
       sh configure_active_hot.sh
}
main
