variable "global" {
  type = object({

    region      = string
    name_prefix = string
    ec2_ami     = string

    common_tags = map(string)

    az                   = list(string)
    cidr_block           = string
    public_subnet_cidrs  = map(string)
    private_subnet_cidrs = map(string)
  })
}