########################
#         IAM          #
########################
# Give ecs perms to run its tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role = aws_iam_role.ecs_task_execution_role.name

  # Attach AWS managed policy to role for necessary ECS task execution permissions
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECR Pull image
resource "aws_iam_policy" "ecs_ecr_pull_images" {
  name = "${local.cluster_name}-ecs-ecr-pull-images"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_pull_images_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_pull_images.arn
}

# Cloud Watch logs
resource "aws_iam_policy" "ecs_cloudwatch_logs" {
  name = "${local.cluster_name}-logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

# Cloud Watch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${local.cluster_name}"
  retention_in_days = 1
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs.arn
}

# SSM Parameter Access
resource "aws_iam_policy" "ecs_ssm_access" {
  name = "${local.cluster_name}-ecs-ssm-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:*:847399026905:parameter/${var.ssm_git_private_key_name}"
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ssm_access_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ssm_access.arn
}

# S3 Access
resource "aws_iam_policy" "mc_allow_ecs_to_s3" {
  name = "${local.cluster_name}-ecs-allow-ecs-to-s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          var.minecraft_world_s3_bucket,
          var.minecraft_assets_s3_bucket
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "${var.minecraft_world_s3_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:CreateMultipartUpload"
        ]
        Resource = [
          "${var.minecraft_assets_s3_bucket}/*/assets/world_bck_up/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mc_allow_ecs_to_s3_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.mc_allow_ecs_to_s3.arn
}