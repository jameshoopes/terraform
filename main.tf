provider "aws" {
	region="us-east-1"
}

data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "jhlcfg" {
	image_id		=	"ami-40d28157"
	instance_type	=	"t2.micro"
	security_groups	= ["${aws_security_group.instance.id}"]
	
	user_data		=	<<-EOF
						#!/bin/bash
						echo "Hello, World!" > index.html
						nohup busybox httpd -f -port
						${var.server_port}" &
						EOF
	lifecycle {
		create_before_destroy	=	true
	}
}

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default=8080
}

resource "aws_instance" "jhtest" {
ami						=	"ami-40d28157"
instance_type			=	"t2.micro"
vpc_security_group_ids	=	["${aws_security_group.jhtestsg.id}"]

user_data		=	<<-EOF
					#!/bin/bash
					echo "Hello World!" > index.html
					nohup busybox httpd -f -p 
					"${var.server_port}" &
					EOF

tags {
	Name="Terraform-Example"
	}
}

resource "aws_autoscaling_group" "jhautosc" {
	launch_configuration	=	"${aws_launch_configuration.jhlcfg.id}"
	availability_zones		=	["${data.aws_availability_zones.all.names}"]
	
	min_size	=	2
	max_size	=	10
	
	tag {
	key					=	"Name"
	value				=	"terraform-asg-example"
	propagate_at_launch	=	true
	}
}

resource "aws_elb" "jhelb" {
	name				=	"terraform-asg_example"
	availability_zones	=	["${data.aws_availability_zones.all.names}"]
}

resource "aws_security_group" "jhtestsg" {
	name	=	"terraform-example-instance"
	
	ingress {
	from_port	=	"${var.server_port}"
	to_port		=	"${var.server_port}"
	protocol	=	"tcp"
	cidr_blocks	=	["12.155.228.3/32"]
	}
	
	lifecycle {
		create_before_destroy	=	true
	}
}

output "public_ip" {
value="${aws_instance.jhtest.public_ip}"
}