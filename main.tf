provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVERS
# ---------------------------------------------------------------------------------------------------------------------
module "consul-servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.0.5"

  cluster_name  = "${var.cluster_name}-server"
  cluster_size  = "${var.num_servers}"
  instance_type = "t2.micro"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"

  root_volume_size = 50

  ami_id    = "${var.consul_server_ami}"
  user_data = "${data.template_file.consul_server.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["subnet-9b6783c2","subnet-aa1ae0dd","subnet-bbaaae93"]

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVERS
# ---------------------------------------------------------------------------------------------------------------------
module "nomad-servers" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.0.5"

  cluster_name  = "nomad-server"
  cluster_size  = "${var.num_of_nomad_servers}"
  instance_type = "t2.micro"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"

  root_volume_size = 50

  ami_id    = "${var.consul_server_ami}"
  user_data = "${data.template_file.nomad_server.rendered}"


  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["subnet-9b6783c2","subnet-aa1ae0dd","subnet-bbaaae93"]

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"

}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL CLIENT FOR SPARK
# ---------------------------------------------------------------------------------------------------------------------
module "spark" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.0.5"

  cluster_name  = "spark-instance"
  cluster_size  = 1
  instance_type = "t2.xlarge"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"

  root_volume_size = 300

  ami_id    = "${var.consul_server_ami}"
  user_data = "${data.template_file.spark_client.rendered}"


  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["subnet-9b6783c2","subnet-aa1ae0dd","subnet-bbaaae93"]

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"

}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL CLIENT FOR KINETICA
# ---------------------------------------------------------------------------------------------------------------------

module "gpu-clients" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.0.5"

  cluster_name  =  "kinetica-node"
  cluster_size  = 1
  instance_type = "p2.xlarge"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"

  root_volume_type = "gp2"
  root_volume_size = 500

  wait_for_capacity_timeout="2m"

  ami_id    = "${var.gpu_ami}"
  user_data = "${data.template_file.consul_client.rendered}"


  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["subnet-9b6783c2","subnet-aa1ae0dd","subnet-bbaaae93"]

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

data "template_file" "consul_server" {
  template = "${file("${path.module}/scripts/start-consul-server.sh")}"

  vars {
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"
  }
}
data "template_file" "nomad_server" {
  template = "${file("${path.module}/scripts/start-nomad-server.sh")}"

  vars {
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_name}"
  num_of_servers = "${var.num_of_nomad_servers}"
  }
}
data "template_file" "consul_client" {
  template = "${file("${path.module}/scripts/start-kinetica.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_name}"
  }
}
data "template_file" "spark_client" {
  template = "${file("${path.module}/scripts/start-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_name}"
  }
}
resource "aws_security_group_rule" "nomad_servers_all_traffic" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${module.nomad-servers.security_group_id}"
}
resource "aws_security_group_rule" "spark_all_traffic" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${module.spark.security_group_id}"
}
resource "aws_security_group_rule" "consul_clients_all_traffic" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${module.gpu-clients.security_group_id}"
}
