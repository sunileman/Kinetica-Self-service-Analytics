#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-nomad and run-consul scripts to configure and start Nomad and Consul in client mode. Note that this script
# assumes it's running in an AMI built from the Packer template in examples/nomad-consul-ami/nomad-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# These variables are passed in via Terraform template interplation
#sudo service docker start
#sudo /opt/consul/bin/run-consul --client --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example
#nohup consul agent -retry-join "provider=aws region=us-east-1 tag_key=consul-cluster tag_value=consul-cluster-example" -bind=127.0.0.1 -data-dir=/tmp/consul &

#get kinetica consul service def
wget https://s3.amazonaws.com/kinetica-se/consul/kinetica.json -P /home/centos

#get the instance region
instance_identity_doc=$(curl --silent --show-error --location http://169.254.169.254/latest/dynamic/instance-identity/document)
instance_region=$(echo $instance_identity_doc | jq -r ".region")

#get the private ip
internal_ip=$(curl --silent --show-error --location http://169.254.169.254/latest/meta-data/local-ipv4 )

public_hostname=$(curl --silent --show-error --location http://169.254.169.254/latest/meta-data/public-hostname )

#get the instance id
instance_id=$(curl --silent --show-error --location http://169.254.169.254/latest/meta-data/instance-id )

#create directory
mkdir /tmp/consul

#start consul client agent
nohup consul agent -retry-join "provider=aws tag_key=${cluster_tag_key} tag_value=${cluster_tag_value}" -bind=$internal_ip -data-dir=/tmp/consul -datacenter=$instance_region -node=$instance_id -log-level=DEBUG &> /tmp/consul/consul.log&
sleep 60s
sudo service docker start

#build nvidia-docker image for kinetica
nvidia-docker build -t kinetica/centos6.1 /home/centos

#run kinetica docker image
docker run --runtime=nvidia -it -d -p 8080:8080 -p 8088:8088 -p 9292:9292 -p 9191-9199:9191-9199 --rm kinetica/centos6.1:latest

#update kinetica consul def with correct service dns
sed -i "s/127.0.0.1/$public_hostname/g" "payload.json"

#register kinetica service with consul
curl --request PUT --data @/home/centos/kinetica.json  http://localhost:8500/v1/agent/service/register

