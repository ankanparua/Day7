resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "pubsub"
  }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}
resource "aws_eip" "myeip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "publicRT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynat.id
  }
  tags = {
    Name = "privateRT"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.privateRT.id
}

resource "aws_security_group" "publicSG" {
  name        = "publicSG"
  description = "Allow TCP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "allow_TCP"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.publicSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.publicSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.publicSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_public" {
  security_group_id = aws_security_group.publicSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "privateSG" {
  name        = "privateSG"
  description = "Allow TCP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "allow_TCP"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id            = aws_security_group.privateSG.id
  referenced_security_group_id = aws_security_group.publicSG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_private" {
  security_group_id = aws_security_group.privateSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "example" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.pubsub.id
  vpc_security_group_ids = [ aws_security_group.publicSG.id ]

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "myapp" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.pvtsub.id
  vpc_security_group_ids = [ aws_security_group.privateSG.id ]

  tags = {
    Name = "GoodbyeWorld"
  }
}
