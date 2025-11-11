resource "aws_ssm_association" "run-shell-script" {
  association_name            = "${var.global.name_prefix}-run-shell-script"
  name                        = "AWS-RunShellScript" # 実行するSSMドキュメント名を指定

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

  # ドキュメントに渡すパラメータ
  parameters = {
    commands = join("\n", [
      "#!/bin/bash",
      "echo 'Hello World! from SSM Run Command'"
    ])
  }
}
