# Add enforce autoscaling if task type is for fargate
resource "aws_appautoscaling_target" "ecs_target" {
  count              = length(var.autoscaling_policies) > 0 ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_arn}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  count = length(var.autoscaling_policies)

  name               = var.autoscaling_policies[count.index].name
  policy_type        = var.autoscaling_policies[count.index].policy_type
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = var.autoscaling_policies[count.index].policy_type == "TargetTrackingScaling" ? [1] : []
    content {
      target_value       = var.autoscaling_policies[count.index].target_value
      scale_in_cooldown  = var.autoscaling_policies[count.index].scale_in_cooldown
      scale_out_cooldown = var.autoscaling_policies[count.index].scale_out_cooldown
      disable_scale_in   = var.autoscaling_policies[count.index].disable_scale_in

      predefined_metric_specification {
        predefined_metric_type = var.autoscaling_policies[count.index].metric_type
      }
    }
  }

  dynamic "step_scaling_policy_configuration" {
    for_each = var.autoscaling_policies[count.index].policy_type == "StepScaling" ? [1] : []
    content {
      adjustment_type         = "ChangeInCapacity"
      cooldown                = var.autoscaling_policies[count.index].scale_out_cooldown
      metric_aggregation_type = "Average"

      step_adjustment {
        scaling_adjustment          = 1
        metric_interval_lower_bound = 0
      }

      step_adjustment {
        scaling_adjustment          = -1
        metric_interval_upper_bound = 0
      }
    }
  }
}