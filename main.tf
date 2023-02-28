resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "Project codica"
 }
}

resource "aws_instance" "Ubuntu" {
  ami           = "ami-05b457b541faec0ca"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnets[0].id
  key_name      = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids  = [aws_security_group.http_sg.id, aws_security_group.ssh-4-all-sg.id]

}

resource "aws_db_instance" "codica" {
  allocated_storage    = 10
  db_name              = "wordpress"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "codica"
  password             = "rOYdrOlIAntR"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.dbcodica.id
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
}

resource "aws_db_subnet_group" "dbcodica" {
  name       = "codica"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  
  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
data "aws_availability_zones" "azs" {
  state    = "available"
}
resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(data.aws_availability_zones.azs.names, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "Project codica"
 }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "public-route-table"
}
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "private-route-table"
}
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnets[0].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnets[1].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnets[0].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnets[1].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "public_1" {
  route_table_id = aws_route_table.public.id
  gateway_id     = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_nat_gateway" "private_1" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_subnets[0].id
}

resource "aws_nat_gateway" "private_2" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_subnets[1].id
}

resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.private_1.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_key_pair" "master-key" {
  key_name   = "terraform"
  public_key = file("./addons/terraform.pub")
}



resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  security_groups = [aws_security_group.http_sg.id]

  
}

resource "aws_lb_target_group" "my_target_group" {
  name_prefix     = "mytarg"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.main.id
  
  health_check {
    path = "/"
    matcher = "200-299,301,302"
    enabled = true
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.Ubuntu.id
  port             = 80
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}



resource "aws_eip" "web" {
  vpc = true
  tags = {
    Name = "Elastic-for-VPC.main"
  }
}

resource "aws_eip_association" "web" {
  instance_id   = "${aws_instance.Ubuntu.id}"
  allocation_id = "${aws_eip.web.id}"

}