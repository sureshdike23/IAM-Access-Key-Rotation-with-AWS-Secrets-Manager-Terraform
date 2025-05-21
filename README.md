# 🛡️ IAM Access Key Rotation with AWS Secrets Manager & Terraform

This repo contains a complete plug-and-play setup to **automatically rotate IAM access keys** using AWS Lambda, Secrets Manager, and Terraform.

---

## 🔧 Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/sureshdike23/IAM-Access-Key-Rotation-with-AWS-Secrets-Manager-Terraform.git
cd IAM-Access-Key-Rotation-with-AWS-Secrets-Manager-Terraform
```

### 2. Update your config

Edit `terraform.tfvars`:

```hcl
user_name              = "your-iam-user"
secret_name            = "your-iam-user-access-key"
rotation_interval_days = 7
alert_email            = "you@example.com"
```

### 3. Zip Lambda Code

```bash
cd lambda
zip rotate_key.zip rotate_key.py
cd ..
```

### 4. Deploy with Terraform

```bash
terraform init
terraform apply
```

✅ Accept SNS email confirmation

### 🔁 Test Rotation

```bash
aws secretsmanager rotate-secret --secret-id your-iam-user-access-key
```

Then:
- ✅ Check Secrets Manager for new keys
- ✅ Check IAM for access key rotation
- ✅ Confirm Lambda logs and SNS alert

---
