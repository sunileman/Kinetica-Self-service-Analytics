# Kinetica-as-a-Service
Building Kinetica as a Service using packer/terraform/consul/nomad

##Setup

1.	Download & Install Packer
2.	Download & Install Terraform
3.	Download this repo
4.	Create GPU AMI
    4a. Run packer build nomad-consul-gpu-centos.json
5.	Create Consul/Nomad AMI
    5a. Run packer build nomad-consul.json
6.	Update the following variables in variables.tf to match your aws environment.  All the variable definitions are available in variables.tf
```
a.	aws_region
b.	ssh_key_name
    i.	This will allow ssh’ing into provision nodes
c.	key_path
    i.	Path to ssh key
d.	vpc_id
e.	aws_access_key
f.	aws_secret_key
g.	gpu_ami
    i.	ami id generated from step 4a
h.	nomad_consul_ami
    i.	ami id generated from step of 5a
6.	Run terraform init
    a.	Must be run inside directory which has main.tf
    b.	Downloads all modules referenced insides main.tf
7.	Run terraform apply
    a.	Must be run inside directory which has main.tf
```
Wait a few minutes for provising.  Once all has been provisioned, you will see:
```
3 consul server nodes
1 nomad server nodes
1 node with Kinetica docker instance
1 node with dockerized spark and nifi instances
```
