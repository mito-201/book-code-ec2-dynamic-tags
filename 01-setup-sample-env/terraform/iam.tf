# iam.tf (この場合の最小構成に近い例)

resource "aws_iam_role" "ec2_ssm_codedeploy_role" {
  name = "${var.global.name_prefix}-ec2-ssm-cd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
  tags = { Name = "${var.global.name_prefix}-ec2-ssm-cd-role" }
}

# SSM Agentが機能するための基本的な管理ポリシー
resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.ec2_ssm_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CodeDeployエージェントがS3からデプロイパッケージをダウンロードするためのポリシー
resource "aws_iam_policy" "ec2_s3_codedeploy_read_policy" {
  name        = "${var.global.name_prefix}-ec2-s3-codedeploy-read"
  description = "Allows EC2 (CodeDeploy agent) to get objects from CodePipeline artifact S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowReadFromDeploymentBuckets",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
          # "s3:ListBucket" # 必要に応じて (特定のパス以下のオブジェクト一覧など)
        ],
        Resource = [
          # CodePipelineのアーティファクトストア
          "arn:aws:s3:::${var.global.name_prefix}-s3-codepipeline",
          "arn:aws:s3:::${var.global.name_prefix}-s3-codepipeline/*",
          # S3ソースアクションで使用するバケット
          "arn:aws:s3:::${var.global.name_prefix}-s3-artifact",
          "arn:aws:s3:::${var.global.name_prefix}-s3-artifact/*",
          # SSM State Managerで使用するバケット
          "arn:aws:s3:::${var.global.name_prefix}-s3-ssm-artifact",
          "arn:aws:s3:::${var.global.name_prefix}-s3-ssm-artifact/*",
        ]
      }
    ]
  })
  tags = { Name = "${var.global.name_prefix}-ec2-s3-codedeploy-read" }
}

resource "aws_iam_role_policy_attachment" "ec2_s3_codedeploy_read_attach" {
  role       = aws_iam_role.ec2_ssm_codedeploy_role.name
  policy_arn = aws_iam_policy.ec2_s3_codedeploy_read_policy.arn
}

resource "aws_iam_policy" "ssm_logging_policy" {
  name        = "${var.global.name_prefix}-ssm-logging-policy"
  description = "Allows SSM Run Command to write logs to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3へのログ書き込み
      {
        Sid    = "AllowSSMLoggingToS3",
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        # ログを保存するバケット
        Resource = "arn:aws:s3:::${var.global.name_prefix}-ssm-logs",
        Resource = "arn:aws:s3:::${var.global.name_prefix}-ssm-logs/*"
      }
    ]
  })
  tags = { Name = "${var.global.name_prefix}-ssm-logging-policy" }
}

resource "aws_iam_role_policy_attachment" "ssm_logging_attach" {
  role       = aws_iam_role.ec2_ssm_codedeploy_role.name
  policy_arn = aws_iam_policy.ssm_logging_policy.arn
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_ssm_codedeploy_profile" {
  name = "${var.global.name_prefix}-ec2-ssm-cd-profile"
  role = aws_iam_role.ec2_ssm_codedeploy_role.name
}
