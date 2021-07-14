###############output_block###################
output "instance_ip" {
  description = "IP address of the instance"
  value       = aws_instance.wordpress-server1[*].public_ip
}
output "instance_ami" {
  description = "AMI of the instance"
  value       = data.aws_ami.ubuntu.id
}
output "ids" {
  description = "AWS subnet ID's"
  value       = data.aws_subnet_ids.www.ids
#  depends_on = [aws_subnet.timur_subnet_az]
}

output "instance_ids" {
  description = "instance ID's"
  value       = data.aws_instances.timurwpec2.ids
}


output "aws_vpc_id" {
  description = "AWS vps ID"
  value       = data.aws_vpc.timur_vpc.id
}

#output "interfaces" {
#  description = "AWS interfaces ID's"
#  value       = data.aws_subnet_ids.www.ids
#  value       =  data.aws_network_interface.bar.id
#  depends_on = [aws_subnet.timur_subnet_az]
#}

output "lb_name" {
    description = ""
    value       = "${aws_elb.timur-lb.name}"
}

output "lb_arn" {
    description = "ARN of the lb itself. Useful for debug output, for example when attaching a WAF."
    value       = "${aws_elb.timur-lb.arn}"
}
output "lb_arn_instances" {
    description = "ARN suffix of our lb - can be used with CloudWatch"
    value       = "${aws_elb.timur-lb.instances}"
}

output "lb_dns_name" {
    description = "The DNS name of the lb presumably to be used with a friendlier CNAME."
    value       = "${aws_elb.timur-lb.dns_name}"
}

output "lb_id" {
    description = "The ID of the lb we created."
    value       = "${aws_elb.timur-lb.id}"
}

output "lb_zone_id" {
    description = "The zone_id of the lb to assist with creating DNS records."
    value       = "${aws_elb.timur-lb.zone_id}"
}
#output "target_group_arn" {
#    description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
#    value       = "${aws_lb_target_group.timur-target-group.arn}"
#}

output "efs_system_name" {
    description = "DNS name of efs file system"
    value       = "${aws_efs_file_system.efs.dns_name}"
}

output "mysql_availability_zone" {
     description = "DNS name of efs file system"
     value       = "${aws_db_instance.timur-mysql.availability_zone}"
}

output "timur-mysql_address" {
     description = "name of mysql instance"
     value       = "${aws_db_instance.timur-mysql.address}"
}

output "mysql_arn" {
     description = "arn name of mysql instance"
     value       = "${aws_db_instance.timur-mysql.arn}"
}

output "mysql_endpoint"{
     description = "endpoint of mysql instance"
     value       = "${aws_db_instance.timur-mysql.endpoint}"
}

output "timur-mysql_id" {
     description = "arn name of mysql instance"
     value       = "${aws_db_instance.timur-mysql.id}"
}

