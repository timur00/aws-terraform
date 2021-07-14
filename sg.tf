##########security_groups##################
resource "aws_security_group" "efs" {
  name        = "wordpress_efs"
  vpc_id      =  aws_vpc.timur_vpc.id
  description = "WordPress EFS"
}
resource "aws_security_group" "db" {
  name        = "wordpress_db"
  vpc_id      =  aws_vpc.timur_vpc.id 
  description = "WordPress Database"
}

resource "aws_security_group" "instance" {
  name        = "wordpress"
  vpc_id      =  aws_vpc.timur_vpc.id 
  description = "WordPress EC2"
}

resource "aws_security_group" "elb" {
  name        = "WordPress ELB"
  vpc_id      =  aws_vpc.timur_vpc.id
  description = "Control the access to the ELB."
}


### создаем security group rules###################

resource "aws_security_group_rule" "elb_ingress_http_all" {
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group_rule" "elb_egress_http" {
  security_group_id = "${aws_security_group.elb.id}"
  source_security_group_id       = "${aws_security_group.instance.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group_rule" "instance_ssh" {
  security_group_id = "${aws_security_group.instance.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_security_group_rule" "ec2_ingress_http" {
  security_group_id = "${aws_security_group.instance.id}"
  type              = "ingress"
  source_security_group_id       = "${aws_security_group.elb.id}"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group_rule" "ec2_egress_reply" {
  security_group_id = "${aws_security_group.instance.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  from_port         = 0
  to_port           = 0 
}

resource "aws_security_group_rule" "efs_egress_reply" {
  security_group_id = "${aws_security_group.efs.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "efs_ingress_ec2" {
  security_group_id = "${aws_security_group.efs.id}"
  type              = "ingress"
  source_security_group_id       = "${aws_security_group.instance.id}"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
}

resource "aws_security_group_rule" "rds_ingress_mysql" {
  security_group_id = "${aws_security_group.db.id}"
  type              = "ingress"
  source_security_group_id       = "${aws_security_group.instance.id}"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
}

resource "aws_security_group_rule" "rds_egress_mysql" {
  security_group_id = "${aws_security_group.db.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  from_port         = 0
  to_port           = 0
}

