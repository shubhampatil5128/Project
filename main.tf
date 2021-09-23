provider "aws" {
  region= "us-east-2"
  
}
resource "aws_vpc" "argo" {
  cidr_block       = "172.17.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "argo-vpc"
  }
}

resource "aws_subnet" "publicsub" {
  vpc_id            = aws_vpc.argo.id
  cidr_block        = "172.17.0.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "publicsub"
  }
}

/*resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.jenkins.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "public2"
  }
}*/

resource "aws_internet_gateway" "argo-igw" {
  vpc_id = aws_vpc.argo.id

  tags = {
    Name = "argo-igw"
  }
}

resource "aws_route_table" "argo-route" {
  vpc_id = aws_vpc.argo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.argo-igw.id
  }

  tags = {
    Name = "argo-route"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsub.id
  route_table_id = aws_route_table.argo-route.id
}

/*resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.jenkins-route.id
}*/

/*resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.jenkins.id
  subnet_ids = [aws_subnet.public.id]

  egress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 250
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "main"
  }
}

/*resource "aws_network_acl" "main2" {
  vpc_id = aws_vpc.jenkins.id
  subnet_ids = [aws_subnet.public2.id]

  egress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 250
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "main2"
  }
}*/

resource "aws_security_group" "argo-sg" {
  name        = "argo-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      =  aws_vpc.argo.id

  ingress {
    description = "HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "argo port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "argo-sg"
  }
}

/*resource "aws_ebs_volume" "jenkins" {
  availability_zone = "us-east-2a"
  size              = 12

  tags = {
    Name = "jenkins"
  }
}

resource "aws_volume_attachment" "ebs_jen" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins.id
  instance_id = aws_instance.jenkins.id
}*/

resource "aws_instance" "argo" {
  ami                         = "ami-01e36b7901e884a10"
  instance_type               = "t2.medium"
  subnet_id                   =  aws_subnet.publicsub.id
  vpc_security_group_ids      =  ["${aws_security_group.argo-sg.id}"]
  associate_public_ip_address = true
  key_name                    = "shu"

}

