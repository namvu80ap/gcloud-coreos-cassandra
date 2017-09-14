#!/bin/bash
# Create Production cluster control

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
step_machine_type=f1-micro

instance_name=gc-step

# get the latest full image name
image=$(gcloud compute images list --project=$project | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create an instance
gcloud compute instances create $instance_name --project=$project --image=$image \
 --image-project=coreos-cloud --boot-disk-size=50 --zone=$zone \
 --machine-type=$step_machine_type --metadata-from-file \
 user-data=cloud-config/master.yaml \
 --no-address --tags=$instance_name,gc-cluster

# create a static IP for the new instance
gcloud compute routes create ip-10-222-1-1-$instance_name --project=$project \
         --next-hop-instance $instance_name \
                  --next-hop-instance-zone $zone \
                           --destination-range 10.222.1.1/32

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
