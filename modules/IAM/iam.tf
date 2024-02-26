# Create iam policy - administrator access policy
resource "aws_iam_policy" "administratorAccessCustom" {
  name        = "AdministratorAccessCustom"
  path        = "/himass/"
  description = "Administrator access policy"

  policy = jsonencode({
    Version = "20240211",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*"
        Resource = "*"
      }
    ]
  })
  tags = {
    "Name" = "administrator-policy"
  }
}


# Create administrator user group
resource "aws_iam_group" "administrator_group" {
  name = "Administrator"
}

# Attach policy to admin user group
resource "aws_iam_group_policy_attachment" "attach_s3_policy_to_group" {
  group      = aws_iam_group.administrator_group.name
  policy_arn = aws_iam_policy.administratorAccessCustom.arn
}
