############################################
# Secrets Manager: DB password + ECS access
############################################

# Store DB password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "${local.name}/db_password"
}

resource "aws_secretsmanager_secret_version" "db_password_v1" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

# Allow ECS task *execution role* to read secret at runtime
data "aws_iam_policy_document" "ecs_secrets_read" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.db_password.arn]
  }

  # Needed when secret is encrypted with KMS (including default AWS-managed key)
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_secrets_read" {
  name   = "${local.name}-ecs-secrets-read"
  policy = data.aws_iam_policy_document.ecs_secrets_read.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_secrets_read" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_secrets_read.arn
}
