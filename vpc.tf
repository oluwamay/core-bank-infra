# Create VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

#Create subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags={
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags={
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags={
    Name = "public_subnet_2"
  }
}

#Create Internet gateway
resource "aws_internet_gateway" "custom_vpc_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_vpc_igw"
  }
}

# Define route table 
resource "aws_route_table" "custom_vpc_public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_vpc_igw.id
  }

  tags = {
    Name = "custom_vpc_public_rt"
  }

}

# Associate route table with subnets
resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.custom_vpc_public_rt.id
}

resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.custom_vpc_public_rt.id
}

# Create Elastic IP
resource "aws_eip" "custom_vpc_eip" {
  domain ="vpc"
  depends_on = [ aws_nat_gateway.custom_vpc_nat_gateway ]
}

# Associate nat gateway with private subnet
resource "aws_nat_gateway" "custom_vpc_nat_gateway" {
  allocation_id = aws_eip.custom_vpc_eip.id
  subnet_id = aws_subnet.public_subnet_1.id
  depends_on = [ aws_internet_gateway.custom_vpc_igw ]
  
  tags = {
    Name = "custom_vpc_nat_gateway"
  }
}

#Create route table for private subnet
resource "aws_route_table" "custom_vpc_private_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.custom_vpc_nat_gateway.id
    }

    tags = {
      Name = "custom_vpc_private_rt"
    }
}

# Associate route table with private subnet
resource "aws_associate_route_table" "private_subnet_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.custom_vpc_private_rt.id
}