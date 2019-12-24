# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# Create IGW and attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = "${merge(var.tags, map("Name", format("%s-igw", var.name)))}"
}

# Create public route table on VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = "${merge(var.tags, map("Name", format("%s-rt-public", var.name)))}"
}

# Create route for IGW
resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

# Attach private NAT gateway to route
resource "aws_route" "private_nat_gateway" {
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  count = "${var.enable_nat_gateway ? length(var.azs) : 0}"
}

# Create private route tables
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.azs)}"
  tags = "${merge(var.tags, map("Name", format("%s-rt-private-%s", var.name, element(var.azs, count.index))))}"
}

# Create private subnets
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.cidr, 8, count.index + 1 + length(var.azs))}"
  availability_zone = "${element(var.azs, count.index)}"
  count = "${length(var.azs)}"
  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-subnet-private-%s", var.name, element(var.azs, count.index))))}"
}

# Create public subnets
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.cidr, 8, count.index + 1)}"
  availability_zone = "${element(var.azs, count.index)}"
  count = "${length(var.azs)}"
  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-subnet-public-%s", var.name, element(var.azs, count.index))))}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}

# Assign elastic IP for NAT gateway
resource "aws_eip" "nateip" {
  vpc = true
  count = "${var.enable_nat_gateway ? length(var.azs) : 0}"
}

# Create NAT GW.  This checks if the enable_nat_gateway variable evaluates to true and if so creates a resource for each element in the azs variable
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  count = "${var.enable_nat_gateway ? length(var.azs) : 0}"
  depends_on = [aws_internet_gateway.igw]
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count = "${length(var.azs)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count = "${length(var.azs)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


