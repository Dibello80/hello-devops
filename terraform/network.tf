data "aws_vpc" "default" {
  id = "vpc-09d87a53226fdd253"
}

data "aws_subnet" "existing" {
  id = "subnet-0c1b18b2f1907e825"
}

data "aws_security_group" "existing" {
  id = "sg-010551cbd7c338a92"
}