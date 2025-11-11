global = {
  region      = "us-west-2"             # 任意のリージョンを指定
  name_prefix = "autoops2"              # 全リソースの接頭語を指定
  ec2_ami     = "ami-06d455b8b50b0de4d" # Amazon Linux 2023。リージョンに合わせて変更する

  # 各リソースに付けるタグを定義
  common_tags = {
    Environment = "dev"
    Product     = "autoops2"
    ManagedBy   = "Terraform"
  }

  az         = ["a", "b", "c"] # AZを指定。東京リージョンであれば、a、c、dになる
  cidr_block = "10.0.0.0/16"   # VPCのCIDER

  # AZごとのCIDRブロックをマップとして定義
  # a、b、cは、azに合わせる。
  public_subnet_cidrs = {
    "a" = "10.0.1.0/24"
    "b" = "10.0.2.0/24"
    "c" = "10.0.3.0/24"
  }

  private_subnet_cidrs = {
    "a" = "10.0.11.0/24"
    "b" = "10.0.12.0/24"
    "c" = "10.0.13.0/24"
  }
}
