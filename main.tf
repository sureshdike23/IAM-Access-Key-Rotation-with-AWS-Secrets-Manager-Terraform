provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec" {
  name = "iam-key-rotation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "attach-lambda-basic"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_lambda_function" "rotate_key" {
  filename         = "lambda/rotate_key.zip"
  function_name    = "rotate-iam-key"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "rotate_key.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda/rotate_key.zip")
  timeout          = 10
}

resource "aws_secretsmanager_secret" "user_key" {
  name = var.secret_name
  description = "Access keys for ${var.user_name}"
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  secret_id           = aws_secretsmanager_secret.user_key.id
  rotation_lambda_arn = aws_lambda_function.rotate_key.arn
  rotation_rules {
    automatically_after_days = var.rotation_interval_days
  }
}

resource "aws_sns_topic" "alert_topic" {
  name = "iam-key-rotation-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
