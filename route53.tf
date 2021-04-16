resource "aws_sns_topic" "sns" {
  name = "user-updates-topic"
}

resource "aws_cloudwatch_metric_alarm" "xyz2" {
  alarm_name          = "foobar"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.sns.arn]
  ok_actions          = [aws_sns_topic.sns.arn]
  
    dimensions = {
    HealthCheckId = aws_route53_health_check.panda.id
  }
}

resource "aws_route53_health_check" "panda" {
  fqdn              =     format("%s.%s",aws_api_gateway_rest_api.panda.id,"execute-api.us-west-2.amazonaws.com")
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.xyz2.alarm_name
  insufficient_data_health_status = "Healthy"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  cloudwatch_alarm_region = "us-west-2"

  tags = {
    Name = "api-health-check"
  }
}
