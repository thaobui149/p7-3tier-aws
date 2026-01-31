resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.tags, { Name = "${local.name}-db-subnets" })
}

resource "aws_db_instance" "this" {
  identifier        = "${local.name}-db"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  db_name  = "appdb"
  username = "appuser"
  password = var.db_password
}

