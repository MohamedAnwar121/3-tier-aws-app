resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project}-${var.environment}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-${var.environment}-igw" }
}

# ── Public subnets (hosts public ALB) ────────────────────────────────────────
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-${var.environment}-public-${count.index + 1}" }
}

# ── Frontend private subnets ──────────────────────────────────────────────────
resource "aws_subnet" "frontend" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project}-${var.environment}-frontend-${count.index + 1}" }
}

# ── Backend private subnets ───────────────────────────────────────────────────
resource "aws_subnet" "backend" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project}-${var.environment}-backend-${count.index + 1}" }
}

# ── Database private subnets ──────────────────────────────────────────────────
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 31)
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project}-${var.environment}-db-${count.index + 1}" }
}

# ── NAT Gateways (one per AZ for HA) ─────────────────────────────────────────
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  tags   = { Name = "${var.project}-${var.environment}-eip-${count.index + 1}" }
}

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]
  tags          = { Name = "${var.project}-${var.environment}-nat-${count.index + 1}" }
}

# ── Route tables ──────────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project}-${var.environment}-rt-public" }
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = { Name = "${var.project}-${var.environment}-rt-private-${count.index + 1}" }
}

# ── Route table associations ──────────────────────────────────────────────────
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "frontend" {
  count          = 2
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "backend" {
  count          = 2
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
