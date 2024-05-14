module "iam_policy_create" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_create
  description = "IAM policy for creating resources."
  path        = local.iam_path

  policy_hcl = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:Create*",
          "ec2:RunInstances",
          "s3:CreateBucket",
          "iam:Create*",
          "logs:CreateLogGroup",
          "lambda:CreateFunction",
          "dynamodb:CreateTable",
          "events:PutRule",
          "events:PutTargets"
        ],
        "Resource": "*"
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}