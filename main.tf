provider "aws" {
	region="us-east-1"
}

resource "aws_instance" "jhtest" {
ami						=	"ami-40d28157"
instance_type			=	"t2.micro"
vpc_security_group_ids	=	["${aws_security_group.jhtestsg.id}"]

user_data		=	<<-EOF
					#!/bin/bash
					echo "Hello World!" > index.html
					nohup busybox httpd -f -p 8080 &
					EOF

tags {
	Name="Terraform-Example"
	}
}

resource "aws_security_group" "jhtestsg" {
	name	=	"terraform-example-instance"
	
	ingress {
	from_port	=	8080
	to_port		=	8080
	protocol	=	"tcp"
	cidr_blocks	=	["12.155.228.3/32"]
	}
}