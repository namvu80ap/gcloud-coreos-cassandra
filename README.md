# gcloud-coreos-cassandra
gcloud coreos cassandra cluster mode

## Step 1 : Update config file
Update gcloud project id and region
Update machine type

## Step 2 : Create master node
sh ./create_master.sh

## Step 3 : Create master node
sh ./create_node.sh

## Step 4 : Set fleetctl tunnel
export FLEETCTL_TUNNEL=$master_node_ip

fleetctl list-machines

## Step 5 : Start cassandra_master
fleetctl start cassandra_master.service

## Step 6 : Start cassandra_node
fleetctl start cassandra_node.service
