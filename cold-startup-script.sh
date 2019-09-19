#!/bin/bash
set -x

get_data() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/Coldcluster/$metadata/matcherreduced-$metadata.kch  /mnt/md0/matcher.kch
    gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp gs://zapr_bucket/Coldcluster/$metadata/prefilter-$metadata.kch /mnt/md0/prefilter.kch
}

update_tar() {
       sudo supervisorctl stop all
       #Clear all the older artifacts
       rm -rf /mnt/md0/*
       sudo rm -rf /etc/supervisor/conf.d/*
       rm -rf /opt/zapr/prod-active-song-revealer/
       src_tar_location=gs://zapr_bucket/tarballs/cold_ubuntu_auto_deploy.tar.gz
       sudo mkdir /opt/temp
       temp_tar_download_location=/opt/temp/
       dest_location=/opt/zapr/
       gsutil cp $src_tar_location $temp_tar_download_location
       cd $temp_tar_download_location
       tar -xzvf cold_ubuntu_auto_deploy.tar.gz -C /opt/zapr/
       sudo sed -i "s|/opt/bin/prefilter.kch|/mnt/md0/prefilter.kch|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
       sudo sed -i "s|/opt/bin/matcher.kch|/mnt/md0/matcher.kch|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
       sudo sed -i "s|10.1.1.40|172.16.15.226|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
}

update_nginx() {
    metadata=$(curl http://169.254.169.254/0.1/meta-data/attributes/partition)
    sudo sed -i "s|^    location .*$|    location /coldcluster/${metadata} {|" /etc/nginx/sites-enabled/default
    sudo sed -i "s|^            rewrite .*$|            rewrite ^/coldcluster/${metadata}/(.*) /\$1 break;|" /etc/nginx/sites-enabled/default
    sudo service nginx restart
}    

update_song_revealer() {
 sudo sed -i '22s/.*/#  -  name: get ec2 facts /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/cold/song-revealer.yml 
 sudo sed -i '23s/.*/#     action: ec2_metadata_fact/' /opt/zapr/prod-active-song-revealer/deploy/prod/active/cold/song-revealer.yml
 sudo sed -i '24s/.*/#     register: out /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/cold/song-revealer.yml
 sudo sed -i '25s/.*/#  -  debug: var=out /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/cold/song-revealer.yml
} 

update_song_revealer_config() {
 sudo sed -i "s|mongoHostnames=ue-prod-polestar-mongo-secondary.zapr.com|# mongoHostnames=ue-prod-polestar-mongo-secondary.zapr.com |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|isEC2=true|# isEC2=true|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|requireMongoCredential=true|# requireMongoCredential=true |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|mediaMetadataMongoDbName=admin|# mediaMetadataMongoDbName=admin |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|mediaMetadataMongoDbUserName=mongo-admin|# mediaMetadataMongoDbUserName=mongo-admin |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|mediaMetadataCacheRefreshInterval=600 |# mediaMetadataCacheRefreshInterval=600 |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|mediaMetaDataMongoCollection=metadata |# mediaMetaDataMongoCollection=metadata |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|mediaMetaDataMongoCacheMaxSize=10 |# mediaMetaDataMongoCacheMaxSize=10 |g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "58s|.*|#mongo creds \nmongoHostnames=172.16.15.236\nisEC2=false\nrequireMongoCredential=false\nget.mongo.password.from.parameter.store=false\nmediaMetadataMongoDbName=admin\nmediaMetadataMongoDbPassword=admin\nmediaMetadataMongoDbUserName=mongo-admin\nmediaMetadataCacheRefreshInterval=600\nmediaMetaDataMongoCollection=metadata\nmediaMetaDataMongoCacheMaxSize=10|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
}

copy_data() {
  /opt/zapr/prod-active-song-revealer/scripts/kyotoFix.sh
  .//root/script/md0.sh
  update_tar
  get_data
  update_nginx
  mkdir -p /opt/zapr/prod-active-song-revealer/logs
  update_song_revealer_config
  update_song_revealer
  sudo ansible-playbook /opt/zapr/prod-active-song-revealer/deploy/prod/active/cold/song-revealer.yml | tee /opt/zapr/prod-active-song-revealer/logs/deploy.log
}

copy_data
