provider "aws" {
  region        ="us-east-1"
  access_key    ="AKIA6BPTIJWLSVBBQ7UE"
  secret_key    ="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"

}
resource "aws_vpc" "kevinvpc" {
  cidr_block       = "10.0.0.0/16"
 
  tags = {
    Name = "kevin"
  }
}

resource "aws_subnet" "public-subnet" {

  vpc_id     = aws_vpc.kevinvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.kevinvpc.id
  cidr_block = "10.0.2.0/24"


  tags = {
    Name = "private-subnet"
  }
}

resource "aws_security_group" "kevinsg" {
  name        = "kevinsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.kevinvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

 }

  tags = {
    Name = "kevin-sg"
  }
}

resource "aws_internet_gateway" "kevin-igw" {
  vpc_id = aws_vpc.kevinvpc.id

  tags = {
    Name = "kevin-vpc"

  }

}
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.kevinvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kevin-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.kevinvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kevin-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id

}



resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_key_pair" "kevinkey" {
  key_name   = "kevinkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzUskn0dr4sim25gL1pKT5L0aNvBhUV8p4a9kj+Z8NKah82Jc8erHnO2vg6XJ69eMkCKS6Nwn8eJIWIGoVEZLHQXvfe1yjRU04Tuwf6qg3ecF8ZMMGZz+VZOwtMq4XiObUSbHH381UvnFL720o7QnDjb0/Vj3JseACsjUVQFZwSjM87jPyAKj82mnSpkD7yytvGlvmBr44HCTlyhYCdbHf4i3KRJVxjpI7tzR3n0xML6TrrPgOWPRS7kUdX/1JWXMaVh1l6TYMkLzVyBg3lWRKZ6GUird3lOO7UQic/QJbNM/6igPTsdGP203WHEUFBQNG9GA+tRHV1Yl9GswYgkp/ root@ip-172-31-43-116.ap-south-1.compute.internal"
}

resource "aws_instance" "cloudknowledge-instance" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id
 vpc_security_group_ids = [aws_security_group.kevinsg.id]


 key_name       = "kevinkey"


  tags = {
    Name = "kevin-india"


  }
}
resource "aws_instance" "db-instance" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet.id
 vpc_security_group_ids = [aws_security_group.kevinsg.id]
 key_name       = "kevinkey"
  tags = {
    Name = "kevin-belgium"
  }
}
resource "aws_eip" "kevin-ip" {
  instance = aws_instance.cloudknowledge-instance.id
  vpc      = true
}

resource "aws_eip" "kevin-natip" {
   vpc  = true
}

resource "aws_nat_gateway" "kevin-nat" {
  allocation_id = aws_eip.kevin-natip.id

  subnet_id     = aws_subnet.public-subnet.id

  }
