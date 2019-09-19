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
    sudo sed -i "s|^    location .*$|    location /hotcluster/${metadata} {|" /etc/nginx/sites-enabled/default   
    sudo sed -i "s|^            rewrite .*$|            rewrite ^/hotcluster/${metadata}/(.*) /\$1 break;|" /etc/nginx/sites-enabled/default
    sudo service nginx restart
}    

update_song_revealer() {
 sudo sed -i '22s/.*/#  -  name: get ec2 facts /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml 
 sudo sed -i '23s/.*/#     action: ec2_metadata_fact/' /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml
 sudo sed -i '24s/.*/#     register: out /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml
 sudo sed -i '25s/.*/#  -  debug: var=out /' /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml
} 

update_song_revealer_config() {
sudo sed -i "s|se-platform-kafka-cluster-1-broker-1.zapr.com:9092|172.16.15.226:9092|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|ue-adtech-kafkabroker-1.zapr.com:9092|172.16.15.226:9092|g" /opt/zapr/prod-active-song-revealer/config/prod/active/cold/song-revealer-config.j2
sudo sed -i "s|http://169.254.169.254/latest/user-data|http://169.254.169.254/0.1/meta-data/attributes/partition|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mongoHostnames=ue-prod-polestar-mongo-secondary.zapr.com|# mongoHostnames=ue-prod-polestar-mongo-secondary.zapr.com |g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|isEC2=true|# isEC2=true |g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|requireMongoCredential=true|# requireMongoCredential=true|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mediaMetadataMongoDbName=admin|# mediaMetadataMongoDbName=admin|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mediaMetadataMongoDbUserName=mongo-admin|# mediaMetadataMongoDbUserName=mongo-admin|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mediaMetadataCacheRefreshInterval=600|# mediaMetadataCacheRefreshInterval=600|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mediaMetaDataMongoCollection=metadata|# mediaMetaDataMongoCollection=metadata|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|mediaMetaDataMongoCacheMaxSize=10|# mediaMetaDataMongoCacheMaxSize=10|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "58s|.*|#mongo creds \nmongoHostnames=172.16.15.236\nisEC2=false\nrequireMongoCredential=false\nget.mongo.password.from.parameter.store=false\nmediaMetadataMongoDbName=admin\nmediaMetadataMongoDbPassword=admin\nmediaMetadataMongoDbUserName=mongo-admin\nmediaMetadataCacheRefreshInterval=600\nmediaMetaDataMongoCollection=metadata\nmediaMetaDataMongoCacheMaxSize=10|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
sudo sed -i "s|cold.cluster.parition.data.url|# cold.cluster.parition.data.url|g" /opt/zapr/prod-active-song-revealer/config/prod/active/hot/song-revealer-config.j2
}

main() {
    update_tar
    sudo mount -t tmpfs -o size=35G tmpfs /opt/kyoto
    /opt/zapr/prod-active-song-revealer/scripts/kyotoFix.sh
    get_data
    mkdir -p /opt/zapr/prod-active-song-revealer/logs
    update_song_revealer
    update_song_revealer_config
    sudo ansible-playbook /opt/zapr/prod-active-song-revealer/deploy/prod/active/hot/song-revealer.yml | tee /opt/zapr/prod-active-song-revealer/logs/deploy.log
    sudo ansible-playbook /opt/zapr/prod-active-song-revealer/scripts/nginx/nginx_hot.yml
    update_nginx
}
main
