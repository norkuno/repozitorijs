terraform {
  backend "s3" {
    bucket  = "952122846739-group-1"
    key     = "ec2/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}


provider "aws" {
  region = "us-east-2" # Ohio region
}


resource "aws_s3_bucket" "bucket_952122846739_group_1" {
  bucket = "952122846739-group-1"
}

# IGW is already defined in the VPC
# Public Route Table for Public Subnet
resource "aws_route_table" "group-1_public_route_table" {
  vpc_id = "vpc-0cef48f565967b89f"  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0e2d8006868a38976"
  }
}



# Public Subnet 
resource "aws_subnet" "group-1_subnet" {
  vpc_id            = "vpc-0cef48f565967b89f"
  cidr_block        = "172.31.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true  

  tags = {
    Name = "group-1-subnet"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "group-1_public_route_table_association" {
  subnet_id      = "subnet-0ac6e055bbdf5ecbc"
  route_table_id = "rtb-0e35c55ee8a74b9b7"
}

resource "aws_security_group" "group-1_sg" {
  name        = "group-1-security-group"
  description = "Allow HTTP, HTTPS and SSH access"

  # SSH (22) visiem 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (80) visiem
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (443) visiem
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "group-1_ec2" {
  ami             = "ami-002acc74c401fa86b" # Bezmaksas RedHat AMI
  instance_type   = "t2.micro"
  key_name        = "group-1-key" 
  vpc_security_group_ids = ["sg-04ba60c11d3f61931"]
  subnet_id       = "subnet-0ac6e055bbdf5ecbc"
  associate_public_ip_address = true

  tags = {
    Name = "group-1-ec2"
  }
}

# SSH atslēga
resource "aws_key_pair" "group-1_ssh_key" {
  key_name   = "group-1-key"
  public_key = file("~/.ssh/group-1-key.pub") 
}

# Elastic IP resurss
resource "aws_eip" "group-1-elastic-IP" {
    tags = {
    Name = "group-1-elastic-IP"
  }
}

# Elastic IP asociācija ar EC2 instanci
resource "aws_eip_association" "group-1_eip_assoc" {
  instance_id   = "i-0c790c10161653b69"
  allocation_id = "eipalloc-0b1033e0eb47b243d"
}


resource "aws_route53_zone" "group_1_dns_zone" {
name = "64vsk.id.lv"
comment = "group-1 64.vsk"
}
