module "iam_policy_delete" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = local.iam_policy_delete
  description = "IAM policy for deleting resources based on specific tags."
  path        = local.iam_path

  policy_hcl = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:Delete*",
          "ec2:TerminateInstances",
          "ec2:DisassociateAddress",
          "ec2:ReleaseAddress",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "iam:Delete*",
          "logs:DeleteLogGroup",
          "lambda:DeleteFunction",
          "route53:DeleteHostedZone",
          "dynamodb:DeleteTable",
          "events:DeleteRule",
          "events:RemoveTargets"
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
