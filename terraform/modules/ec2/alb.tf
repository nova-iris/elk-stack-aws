resource "aws_lb" "vault_alb" {
  count              = var.create_alb && length(var.public_subnet_ids) > 0 ? 1 : 0
  name               = "vault-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vault_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Project     = "Vault"
  }
}

resource "aws_lb_target_group" "vault_tg" {
  count    = var.create_alb && length(var.public_subnet_ids) > 0 ? 1 : 0
  name     = "vault-tg"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/v1/sys/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Environment = var.environment
    Project     = "Vault"
  }
}

resource "aws_lb_listener" "vault_listener" {
  count             = var.create_alb && length(var.public_subnet_ids) > 0 ? 1 : 0
  load_balancer_arn = aws_lb.vault_alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg[0].arn
  }
}

resource "aws_lb_target_group_attachment" "vault_tg_attachment" {
  count            = var.create_alb && length(var.public_subnet_ids) > 0 ? 1 : 0
  target_group_arn = aws_lb_target_group.vault_tg[0].arn
  target_id        = module.vault_server.id
  port             = 8200
}
