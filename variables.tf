# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------


variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources"
  default     = "cluster"
}

variable "num_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "num_of_nomad_servers" {
  description = "The number of Nomad servers nodes to deploy"
  default     = 1
}

variable "num_clients" {
  description = "The number of Consul client nodes to deploy. You typically run the Consul client alongside your apps, so set this value to however many Instances make sense for your app code."
  default     = 1
}

variable "cluster_tag_key" {
  description = "The tag the EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = "smanjee"
}

variable "key_path" {
  description = "Path to EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster"
  default = "/home/ec2-user/consul/terraform/aws/smanjee.pem"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  default     = "vpc-c3e144a6"
}

variable "subnets" {
  description = "The subnets within VPC in which the nodes will be deployed"
  default= {"0"="subnet-9b6783c2","1"="subnet-aa1ae0dd","2"="subnet-60031905"}
}

variable "aws_access_key" {
  description = "AWS access key"
  default     = ""
}
variable "aws_secret_key" {
  description = "AWS secret key"
  default     = ""
}
variable "nomad_consul_ami" {
  description = "AWS nomad ami"
  default     = "ami-c72ea3bd"
}
variable "gpu_ami" {
  description = "GPU ami"
  default     = "ami-f9d05983"
}
