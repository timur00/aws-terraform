terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}
#######private_key################
resource "aws_key_pair" "keypair1" {
  key_name   = "timurtf-keypairs"
  public_key = file(var.ssh_key)
}
#######создаем vpc########
resource "aws_vpc" "timur_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "timur_vpc"
  }
}
####создаем subnet в разных az###########
resource "aws_subnet" "timur_subnet_az" {
  count = "${length(var.subnet_cidrs)}"
  map_public_ip_on_launch = true
  vpc_id            = aws_vpc.timur_vpc.id
  cidr_block        = "${var.subnet_cidrs[count.index]}"
  availability_zone = "${var.az[count.index]}"
  tags = {
    Name = "subnet_az_${var.az[count.index]}"
  }
}
############ создаем aws_instance#########
resource "aws_instance" "wordpress-server1" {
  count = "${length(var.subnet_cidrs)}"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name         = "debian_main"
  vpc_security_group_ids= [aws_security_group.instance.id]
  depends_on = [aws_db_instance.timur-mysql,]
  associate_public_ip_address = true
  subnet_id = "${element(tolist("${aws_subnet.timur_subnet_az[*].id}"), count.index)}"
  provisioner "file" {
    content     = data.template_file.wordpress.rendered
    destination = "/tmp/wordpress.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wordpress.sh",
      "/tmp/wordpress.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout = "20m"
      agent = false
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }
  provisioner "file" {
    content     = data.template_file.wpconfig.rendered
    destination = "/tmp/wp-config.php"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
   }
  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
   }
  timeouts {
    create = "20m"
  }

  tags = {
    Name = "WordPress-server${var.az[count.index]}"
  }
}

#########создаем старый Elastic Load Balancer#################
resource "aws_elb" "timur-lb" {
  name               = "timur-elb"
  subnets = aws_subnet.timur_subnet_az[*].id
  security_groups = [aws_security_group.elb.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/license.txt"
    interval            = 30
  }

  instances   = aws_instance.wordpress-server1[*].id
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "timur-terraform-elb"
  }
}

#####создаем  efs###########
resource "aws_efs_file_system" "efs" {
  creation_token = "tumur-efs"
  encrypted      = false
  tags = {
    Name = "timur-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.efs.id
  count = "${length(var.subnet_cidrs)}"
  subnet_id   =  element(tolist(data.aws_subnet_ids.www.ids), count.index)
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id
}

########создаем Internet Gateway#############
resource "aws_internet_gateway" "timur-gw" {
  vpc_id = aws_vpc.timur_vpc.id
}

########создаем routing table#############
resource "aws_route_table" "timur-rt" {
  vpc_id            = aws_vpc.timur_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.timur-gw.id
  }

  tags = {
    Name = "timur-rt"
  }
}
#######создаем aws_main_route_table_association################
resource "aws_main_route_table_association" "timur-rt-association" {
  vpc_id         = aws_vpc.timur_vpc.id
  route_table_id = aws_route_table.timur-rt.id
}
###############создаем инстанс с MySql###################
resource "aws_db_instance" "timur-mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t3.micro"
  identifier           = "mysqldb"
  identifier_prefix    = null
  multi_az             = false
  port                 = 3306
  storage_encrypted    = false
  skip_final_snapshot  = true
  snapshot_identifier  = null
  name                   = var.dbname
  username               = var.username
  password               = var.password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.mysqldb.id 
  vpc_security_group_ids =  [aws_security_group.db.id]
}
######создаем db_subnet_group##########

resource "aws_db_subnet_group" "mysqldb" {
  name       = "mysqldb"
  subnet_ids = aws_subnet.timur_subnet_az[*].id

  tags = {
    Name = "Mysql-group"
  }
}



