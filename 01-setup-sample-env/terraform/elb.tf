# Application Load Balancer 
resource "aws_lb" "main" {
  name                       = "${var.global.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false # サンプル用。本番ではtrueを推奨
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.public[var.global.az[0]].id, aws_subnet.public[var.global.az[1]].id, aws_subnet.public[var.global.az[2]].id, ]

  tags = { Name = "${var.global.name_prefix}-alb" }
}

# ターゲットグループ
resource "aws_lb_target_group" "app_http" {
  name        = "${var.global.name_prefix}-tg-app"
  port        = 80     # ターゲットインスタンスのポート
  protocol    = "HTTP" # ALBからターゲットへのプロトコル
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/" # アプリケーションのヘルスチェックパス
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200" # 正常時のHTTPステータスコード
  }

  tags = { Name = "${var.global.name_prefix}-app-http-tg" }
}

# HTTPリスナー
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_http.arn
  }

  tags = {
    Name = "${var.global.name_prefix}-alb-listener-http"
  }
}
