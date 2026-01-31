############################
# ALB Security Group
############################
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-alb-sg"
  })
}

############################
# Application Load Balancer
############################
resource "aws_lb" "app" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.public[*].id

  tags = merge(local.tags, {
    Name = "${local.name}-alb"
  })
}

############################
# Target Group (for ECS later)
############################
resource "aws_lb_target_group" "app" {
  name        = "${local.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, {
    Name = "${local.name}-tg"
  })
}

############################
# Listener :80 -> forward to TG
############################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
