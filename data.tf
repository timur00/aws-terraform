#######data_block##########

#data "aws_vpc" "timur_vpc" {
##  filter {
##    name = "tag:Name"
##    values = ["timur_vps"]
##  }
##}
##
##data "aws_subnet_ids" "timursubnetdata" {
##vpc_id = data.aws_vpc.timur_vps.id
##}
#

#data "aws_network_interface" "bar" {
#id = aws_network_interface.timurinterface[count.index]
#count = 2
#id = element(tolist(data.aws_subnet_ids.www.ids), count.index)
#id    = element(tolist(data.aws_subnet_ids.www.ids, count.index))
#}
data "template_file" "wordpress" {
  template = file("wordpress.sh")
  vars = {
    efs_id = "${aws_efs_file_system.efs.id}"
#    efs_id = aws_efs_file_system.efs.id
  }
}


data "template_file" "wpconfig" {
  template = file("wp-config.php")

  vars = {
    db_port = aws_db_instance.timur-mysql.port
    db_host = aws_db_instance.timur-mysql.address
    db_user = var.username
    db_pass = var.password
    db_name = var.dbname
  }
}

data "aws_vpc" "timur_vpc" {
 id = aws_vpc.timur_vpc.id
}
data "aws_subnet_ids" "www" {
vpc_id = aws_vpc.timur_vpc.id
  filter {
    name   = "tag:Name"
    values = ["subnet_az_*"]
  }
depends_on = [aws_subnet.timur_subnet_az]
}

#data "aws_subnet_ids" "private" {
#vpc_id = aws_vpc.timur_vpc.id
#  filter {   
#    name   = "tag:Name"
#    values = ["subnet_private_*"]
#  }
#depends_on = [aws_subnet.private]
#}
#

#
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_instances" "timurwpec2" {
  filter {
    name   = "tag:Name"
    values = ["WordPress-server*"]
  }
depends_on = [aws_instance.wordpress-server1]
}

