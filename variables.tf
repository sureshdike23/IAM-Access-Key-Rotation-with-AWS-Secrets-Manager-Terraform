variable "aws_region" {
  default = "us-east-1"
}

variable "user_name" {}
variable "secret_name" {}
variable "rotation_interval_days" {
  default = 7
}
variable "alert_email" {}
