resource "aws_s3_bucket" "ssm" {
  bucket = "${var.global.name_prefix}-s3-ssm"
}

resource "aws_s3_bucket" "ssm_artifact" {
  bucket = "${var.global.name_prefix}-s3-ssm-artifact"
}

