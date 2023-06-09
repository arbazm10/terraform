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

resource "aws_key_pair" "a2z" {
  key_name   = "a2z"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVyPY6dSN5i/vyLq5aESmyExJrK85bPIPgsz8FBzbZKMLKnQTiQE+CwUkq+nKtMO4f/bXmzInf400mAeP8/gD0rfGXPdKaNQUwfIaVWkUN8Kwc86ArTPP7uF/9QrujvcOzfGSLr36y0fkFaWX02GP9BmS0i/VnepW/cEheQ0svXBMicKwmWus/SPA1xjjKYDrNcssn77nSMBZX+1cRXd6fQdGlgbYa2lIexJCxfb+nrQbC7Hkgxl99Zkas2PMnzlI+cFB38BSfbs7+2NGd3FmjsZrLmWcsRiFS26k0+msuY6mjQocmh825myJbpr3LFTQ2cn+iF/FKavNkzLe9UY2T a2z"
}

resource "aws_instance" "cloudknowledge-instance" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id
 vpc_security_group_ids = [aws_security_group.kevinsg.id]


 key_name       = "a2z"


  tags = {
    Name = "a2z"


  }
}
resource "aws_instance" "db-instance" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet.id
 vpc_security_group_ids = [aws_security_group.kevinsg.id]
 key_name       = "a2z"
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
