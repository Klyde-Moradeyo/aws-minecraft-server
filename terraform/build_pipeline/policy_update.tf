module "iam_policy_update" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_update
  description = "IAM policy for updating resources with specific tags."
  path        = local.iam_path

  policy_hcl = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:Modify*",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AttachInternetGateway",
          "ec2:AssociateRouteTable",
          "iam:Update*",
          "s3:PutBucket*",
          "logs:PutRetentionPolicy",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTimeToLive",
          "events:PutRule",
          "events:PutTargets"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/Project": data.terraform_remote_state.my_state.outputs.tags["Project"],
            "aws:ResourceTag/Namespace": data.terraform_remote_state.my_state.outputs.tags["Namespace"]
          }
        }
      }
    ]
  }

  tags = data.terraform_remote_state.my_state.outputs.tags
}