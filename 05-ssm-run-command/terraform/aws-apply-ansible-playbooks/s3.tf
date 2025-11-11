data "aws_s3_bucket" "bucket" {
  bucket = "${var.global.name_prefix}-s3-ssm-artifact"
}

resource "aws_s3_object" "zip_upload" {
  bucket = data.aws_s3_bucket.bucket.id
  key    = "playbook.zip"      # S3バケット内でのファイル名
  source = "./playbook.zip"    # .tfファイルと同じ場所にあるZIPファイルへのパス

  # ファイルの内容が変わったら再アップロードするために etag を使う
  etag = filemd5("./playbook.zip")
}