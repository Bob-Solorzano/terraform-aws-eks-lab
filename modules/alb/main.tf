##########################################
# AWS Load Balancer Controller IAM Role
##########################################

resource "aws_iam_role" "alb_controller" {
  name = "${var.environment}-aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"

            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-aws-load-balancer-controller"
    Environment = var.environment
  }
}

##########################################
# AWS Load Balancer Controller IAM Policy
##########################################

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.environment}-aws-load-balancer-controller"
  description = "IAM permissions for the AWS Load Balancer Controller"

  policy = file("${path.module}/policy.json")

  tags = {
    Name        = "${var.environment}-aws-load-balancer-controller"
    Environment = var.environment
  }
}

##########################################
# AWS Load Balancer Controller IAM Policy Attachment
##########################################

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}