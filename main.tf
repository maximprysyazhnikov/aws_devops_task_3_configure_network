########################################
# Subnet (публічна) для Grafana
########################################
resource "aws_subnet" "grafana" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.100.0/24" # ← валідно в межах 172.31.0.0/16
  map_public_ip_on_launch = true

  tags = { Name = "grafana" }
}

########################################
# Internet Gateway
########################################
data "aws_internet_gateway" "attached" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}


########################################
# Route Table + маршрут у інтернет через IGW
########################################
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.attached.id

  }

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

########################################
# Прив’язка Route Table до Subnet
########################################
resource "aws_route_table_association" "grafana_assoc" {
  subnet_id      = aws_subnet.grafana.id
  route_table_id = aws_route_table.public_rt.id
}

########################################
# Security Group (+ окремі правила ingress/egress)
########################################
resource "aws_security_group" "grafana_sg" {
  name        = "mate-aws-grafana-lab"
  description = "Security group for Grafana lab"
  vpc_id      = var.vpc_id

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

# Allow HTTP 80 from anywhere
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow HTTPS 443 from anywhere
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow SSH 22 only from your public IP (/32)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip_cidr
}

# Outbound allow all (для доступу у інтернет)
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow Grafana UI on 3000 from anywhere
resource "aws_vpc_security_group_ingress_rule" "grafana_3000" {
  security_group_id = aws_security_group.grafana_sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = "0.0.0.0/0"
}
