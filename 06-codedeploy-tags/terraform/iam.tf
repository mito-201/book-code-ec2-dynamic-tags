resource "aws_iam_role" "codepipeline_service_role" {
  name = "${var.global.name_prefix}-codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com" # CodePipelineサービスを信頼
        }
      }
    ]
  })

  tags = {
    Name = "${var.global.name_prefix}-codepipeline-service-role"
  }
}

# CodePipelineが必要とする基本的な権限ポリシー
resource "aws_iam_policy" "codepipeline_permissions_policy" {
  name        = "${var.global.name_prefix}-codepipeline-permissions"
  description = "Policy for CodePipeline service role to access necessary resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        Resource = [
          # アーティファクトストア用S3バケットのARNと、その中のオブジェクト
          aws_s3_bucket.codepipeline.arn,
          "${aws_s3_bucket.codepipeline.arn}/*",
          # ソースアクションでS3を使う場合のソースバケットのARNも必要
          "arn:aws:s3:::${var.global.name_prefix}-s3-artifact", # ★S3ソースバケット
          "arn:aws:s3:::${var.global.name_prefix}-s3-artifact/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*" # ★実際にはより具体的に対象リソースを絞ることを推奨
      },
      # CodeBuildを実行する場合は "codebuild:StartBuild", "codebuild:BatchGetBuilds" なども必要
      # 他にパイプラインが操作するサービスの権限もここに追加
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_permissions_attach" {
  role       = aws_iam_role.codepipeline_service_role.name
  policy_arn = aws_iam_policy.codepipeline_permissions_policy.arn
}

resource "aws_iam_role" "codedeploy_service_role" {
  name = "${var.global.name_prefix}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com" # CodeDeployサービスを信頼
        }
      }
    ]
  })
  tags = {
    Name = "${var.global.name_prefix}-codedeploy-service-role"
  }
}

# CodeDeployサービスロールに必要な基本的な権限 (AWS管理ポリシーを利用)
resource "aws_iam_role_policy_attachment" "codedeploy_role_policy_attach" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}