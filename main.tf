# variables to use for AWS authentication 

variable "aws_access_key" {
    default = ""
}

variable "aws_secret_key" {
    default = ""
}


provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-2"
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags = {
    Name = "default vpc for url-shortener"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet for the url-shortener"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group to allow access to the container"
  description = "allow access on ports 8000 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "container access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # done to enable terraform access
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = " url shortener with docker"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


# launch the ec2 instance after creating and downloading a key pair in AWS naamed key_pair 
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "key_pair"
  tags = {
    Name = "shortener server in docker"
  }
}


# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/path/to/the/key/key_pair_for_task.pem")
    host        = aws_instance.ec2_instance.public_ip
  
  }

  # copy the pull-run-shortener.sh from my local computer to the ec2 instance 
  provisioner "file" {
    source      = "pull-run-shortener.sh"
    destination = "/home/ec2-user/pull-run-shortener.sh"
  }

  # set permissions and run the pull-run-shortener.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmode +x /home/ec2-user/pull-run-shortener.sh",  
      "sh /home/ec2-user/pull-run-shortener.sh",
    ]
  }
 
