#!/bin/bash

# install_fleet_etcd_clients.sh
ssh-add ~/.ssh/google_compute_engine &>/dev/null

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat settings | grep zone= | head -1 | cut -f2 -d"=")
# get pro-database-control server's external IP
control_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 pro-control | awk {'print $5'})

# get prod-web1 server's external IP
#web1_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 prod-web1 | awk {'print $5'})

# get prod-web2 server's external IP
#web2_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 prod-web2 | awk {'print $5'})
##

# create main folder and a few subfolders
mkdir -p coreos-prod-gce/bin
mkdir -p coreos-prod-gce/fleet

# copy settings file
cp -f settings coreos-prod-gce/

echo "Install etcdctl, ssh shell and cluster access scripts"
cp -f files/* coreos-prod-gce/bin/
cp -f fleet/* coreos-prod-gce/fleet/
cp -f scripts/* coreos-prod-gce/

echo "set control IP"
# set control IP
sed -i "" "s/control_ip/$control_ip/"  ./coreos-prod-gce/bin/etcdctl
sed -i "" "s/control_ip/$control_ip/"  ./coreos-prod-gce/bin/set_cluster_access.sh

echo "set zone"
# set zone
sed -i "" "s/_ZONE_/$zone/"  ./coreos-prod-gce/bin/database-control.sh
# sed -i "" "s/_ZONE_/$zone/"  ./coreos-prod-gce/bin/web1.sh
# sed -i "" "s/_ZONE_/$zone/"  ./coreos-prod-gce/bin/web2.sh

echo "set project"
# set project
sed -i "" "s/_PROJECT_/$project/"  ./coreos-prod-gce/bin/database-control.sh
# sed -i "" "s/_PROJECT_/$project/"  ./coreos-prod-gce/bin/web1.sh
# sed -i "" "s/_PROJECT_/$project/"  ./coreos-prod-gce/bin/web2.sh

echo "make files executables"
# make files executables
chmod 755 coreos-prod-gce/bin/*


echo "download fleetctl"
# download fleetctl client
# First let's check which OS we use: OS X or Linux
uname=$(uname)

# check remote fleet version
FLEET_RELEASE=$(gcloud compute --project=$project ssh --zone=$zone "core@pro-control" --command "fleetctl version | cut -d ' ' -f 3- | tr -d '\r' ")
cd coreos-prod-gce/bin

if [[ "${uname}" == "Darwin" ]]
then
    # OS X
    echo "Downloading fleetctl v$FLEET_RELEASE for OS X"

    curl -L -o fleet.tar.gz "https://github.com/coreos/fleet/releases/download/v0.11.8/fleet-v0.11.8-linux-amd64.tar.gz"
    # unzip -j -o "fleet.zip" "fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl"
    # mkdir fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl
    sudo tar -xf fleet.tar.gz -C fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl
    rm -f fleet.tar.gz
    # Make them executable
    chmod +x coreos-prod-gce/bin/*
    #
else
    # Linux
    echo "Downloading fleetctl v$FLEET_RELEASE for Linux"
    wget "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-linux-amd64.tar.gz"
    tar -zxvf fleet-v$FLEET_RELEASE-linux-amd64.tar.gz fleet-v$FLEET_RELEASE-linux-amd64/fleetctl --strip 1
    rm -f fleet-v$FLEET_RELEASE-linux-amd64.tar.gz
    # Make them executable
    chmod +x coreos-prod-gce/bin/*
    #
fi
#
cd coreos-prod-gce

echo " "
echo "Install has finished !!!"
pause 'Press [Enter] key to continue...'
