#!/bin/bash
# Create Production cluster workers

# Update required settings in "settings" file before running this script

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=api-project-7872450353
zone=asia-northeast1-c
# CoreOS release channel
channel=stable
# worker instance type
# worker_machine_type=f1-micro
worker_machine_type=n1-standard-1

instance_name=gc-cluster-1

# get the latest full image name
image=$(gcloud compute images list --project=$project | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create cluster instance
gcloud compute instances create $instance_name --project=$project --image=$image \
 --image-project=coreos-cloud --boot-disk-size=100 --zone=$zone \
 --machine-type=$worker_machine_type --metadata-from-file \
 user-data=cloud-config/cluster.yaml --can-ip-forward --tags $instance_name,gc-cluster

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
