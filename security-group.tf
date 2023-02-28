resource "aws_security_group" "rds-sg" {
    name        = "rds-sg"
  description = "Allow MySQL portn for VPC"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "allow 3306 from our public IP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24","10.0.2.0/24","10.0.4.0/24","10.0.5.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Terraform = true
  }
}

resource "aws_security_group" "ssh-4-all-sg" {
    name        = "ssh-4-all-sg"
  description = "Allow SSH for all"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "allow 22 from our public IP"
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
    Terraform = true
  }
}

resource "aws_security_group" "http_sg" {
  name        = "http"
  description = "Allows HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Terraform = true
  }
}