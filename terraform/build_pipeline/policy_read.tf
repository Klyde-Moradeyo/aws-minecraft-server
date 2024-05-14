module "iam_policy_read" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_read
  description = "IAM policy for reading resources."
  path        = local.iam_path

  policy_hcl = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:Describe*",
          "s3:ListBucket",
          "iam:Get*",
          "iam:List*",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "lambda:GetFunction",
          "lambda:ListVersionsByFunction",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",
          "events:DescribeRule",
          "events:ListTagsForResource",
          "events:ListTargetsByRule"
        ],
        "Resource": "*"
      }
    ]
  }
  

  tags = data.terraform_remote_state.my_state.outputs.tags
}
