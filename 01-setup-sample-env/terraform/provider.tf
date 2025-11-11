terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # 最新のバージョンを確認してください
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0" # 最新のバージョンを確認してください
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4" # 最新のバージョンを確認してください
    }
  }
}

provider "aws" {
  # AWS認証情報は環境変数や~/.aws/credentialsから読み込まれる想定
  region = var.global.region

  default_tags {
    tags = var.global.common_tags
  }
}
