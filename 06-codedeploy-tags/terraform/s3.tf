resource "aws_s3_bucket" "codepipeline" {
  bucket = "${var.global.name_prefix}-s3-codepipeline"
}

resource "aws_s3_bucket" "artifact" {
  bucket = "${var.global.name_prefix}-s3-artifact"
}

resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.artifact.id # 上で定義したアーティファクトバケットを参照

  versioning_configuration {
    status = "Enabled" # バージョニングを有効化
  }
}

# コードパイプラインで配布するZipファイルを、S3バケットにアップロードする
# コードパイプラインをterraformで作成すると、作成と同時に実行されるため、
# アップロードは無効化している。有効化はお任せ。
#resource "aws_s3_object" "object" {
#  bucket = aws_s3_bucket.artifact.bucket
#  key    = "install_git.zip"
#  source = "../artifacts/install_git.zip"
#}
