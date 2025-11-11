resource "aws_launch_template" "template" {
  name                   = "${var.global.name_prefix}-template"
  image_id               = var.global.ec2_ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.appserver.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_codedeploy_profile.name # iam.tf で定義されたプロファイル
  }

  user_data = base64encode(
    templatefile(
      "user_data.sh", {
      }
    )
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.global.common_tags, # tfvarsから読み込んだ共通タグ
      {
        # このインスタンス固有のタグ
        Name     = "${var.global.name_prefix}-app-instance"
        Role = "app"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.global.common_tags,
      {
        Name = "${var.global.name_prefix}-app-volume"
      }
    )
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.global.name_prefix}-app-asg"
  vpc_zone_identifier = [
    aws_subnet.private[var.global.az[0]].id,
    aws_subnet.private[var.global.az[1]].id,
    aws_subnet.private[var.global.az[2]].id
  ]

  desired_capacity = 4
  max_size         = 6
  min_size         = 1

  target_group_arns    = [aws_lb_target_group.app_http.arn]
  termination_policies = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.global.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false # ASGリソース自体のNameタグ (インスタンスには継承しない)
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.global.name_prefix}-app-asg"
    propagate_at_launch = false
  }
}
