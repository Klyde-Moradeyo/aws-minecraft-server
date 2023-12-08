resource "aws_cloudwatch_event_rule" "monthly_schedule" {
  name                = "${module.resource_naming.name}-monthly-schedule"
  description         = "Trigger Lambda monthly"
#   schedule_expression = "cron(0 12 1 * ? *)"  # Runs at 12:00 PM UTC on the first day of every month
schedule_expression = "rate(5 minutes)"

  tags = var.tags
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "${module.resource_naming.name}-allow-execution-from-event-bridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monthly_schedule.arn
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.monthly_schedule.name
  target_id = "TriggerLambdaFunction"
  arn       = aws_lambda_function.lambda_function.arn

  input = jsonencode({
    "action" = "mc_world_archive_start"
    "server_template" = "None"
    "reason" = "Event Bridge Trigger"
  })
}
