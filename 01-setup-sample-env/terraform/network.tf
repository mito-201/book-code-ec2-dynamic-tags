# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.global.cidr_block
  tags                 = { Name = "${var.global.name_prefix}-vpc" }
  enable_dns_hostnames = true
}

# インターネットゲートウェイ (VPCに1つ)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.global.name_prefix}-igw" }
}

# パブリックルートテーブル (VPCに1つ)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.global.name_prefix}-rtb-public" }
}

# EIP (NATGW用に1つ作成)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.global.name_prefix}-eip-nat-${var.global.az[0]}" }
}

# NATゲートウェイ (1つ作成)
resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_internet_gateway.main]
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.global.az[0]].id
  tags          = { Name = "${var.global.name_prefix}-natgw" }
}

# プライベートルートテーブル (1つ作成)
resource "aws_route_table" "private" {
  for_each = toset(var.global.az)
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # 対応するNAT GWを参照
  }
  tags = { Name = "${var.global.name_prefix}-rtb-private-${each.key}" }
}

# パブリックサブネット (AZごとに計3つ作成)
resource "aws_subnet" "public" {
  for_each          = var.global.public_subnet_cidrs
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.global.region}${each.key}"
  tags              = { Name = "${var.global.name_prefix}-subnet-public-${each.key}" }
}

# プライベートサブネット (AZごとに計3つ作成)
resource "aws_subnet" "private" {
  for_each          = var.global.private_subnet_cidrs
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.global.region}${each.key}"
  tags              = { Name = "${var.global.name_prefix}-subnet-private-${each.key}" }
}

# S3 VPCエンドポイント (VPCに1つ、全プライベートRTに関連付け)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.global.region}.s3"
  # for_eachで作成したプライベートルートテーブルのIDを動的に収集
  route_table_ids = [for az in var.global.az : aws_route_table.private[az].id]
  tags            = { Name = "${var.global.name_prefix}-vpcendpoint" }
}

# ルートテーブルとサブネットの関連付け
resource "aws_route_table_association" "public" {
  for_each       = toset(var.global.az) # ["a", "b", "c"] のリストでループ
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id # 共通のパブリックRTを参照
}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.global.az) # ["a", "b", "c"] のリストでループ
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id # 対応するプライベートRTを参照
}
