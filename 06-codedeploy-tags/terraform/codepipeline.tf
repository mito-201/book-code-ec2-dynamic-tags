resource "aws_codepipeline" "main" {
  name           = "${var.global.name_prefix}-app"
  role_arn       = aws_iam_role.codepipeline_service_role.arn
  pipeline_type  = "V2"  # バージョン2
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        PollForSourceChanges = "false"
        S3Bucket             = "${var.global.name_prefix}-s3-artifact"
        S3ObjectKey          = "install_git.zip"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["SourceArtifact"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.main.name
        DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }
}
