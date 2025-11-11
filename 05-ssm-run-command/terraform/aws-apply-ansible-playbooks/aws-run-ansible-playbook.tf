
resource "aws_ssm_association" "apply-ansible" {
  association_name = "${var.global.name_prefix}-apply-ansible"
  name             = "AWS-ApplyAnsiblePlaybooks"

  apply_only_at_cron_interval = true                      # terraform apply時の実行をしない
  schedule_expression         = "at(2099-11-26T10:00:00)" # 実現性のないスケジュールを設定

  # ターゲット指定 (AND条件)
  targets {
    key    = "tag:Role"
    values = ["app"]
  }
  targets {
    key    = "tag:Product"
    values = [var.global.common_tags.Product]
  }
  targets {
    key    = "tag:Environment"
    values = [var.global.common_tags.Environment]
  }

  parameters = {
    SourceType = "S3",
    SourceInfo = jsonencode({
      path = "https://s3.amazonaws.com/${var.global.name_prefix}-s3-ssm-artifact/playbook.zip"
    }),
    PlaybookFile        = "main.yml",
    InstallDependencies = "True",
  }
}
