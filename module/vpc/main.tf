resource "aws_vpc" "name" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.name.id
  for_each = var.subnet_config
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name = each.key
  }
}
locals{
    public_subnet = {
    #key={} if public is true in subnet_config
    for key, config in var.subnet_config : key => config if config.public
  }
  private_subnet = {
    #key={} if public is true in subnet_config
    for key, config in var.subnet_config : key => config if !config.public
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.name.id
  count= length(local.public_subnet) > 0 ? 1 : 0
  # tags = {
  #   Name = "igw-${local.public_subnet[count.index].az}"
  # }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id
  count= length(local.public_subnet) > 0 ? 1 : 0
  # route  {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.gw[count.index].id
  # }
  
}
resource "aws_route_table_association" "public" {
  for_each = local.public_subnet
  subnet_id = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public[0].id
}