module "iam_sleuth" {
  source                 = "git@github.com:Guardsman-cyber-intel/terraform-aws-lambda.git" #TODO: add our github source. Lambda AWS
  version                = "2.2.0"
  name                   = "iam_sleuth"
  handler                = "handler.handler"
  job_identifier         = "iam_sleuth"
  runtime                = "python3.8"
  timeout                = "500"
  role_policy_arns_count = 2
  role_policy_arns = ["${aws_iam_policy.sleuth_policy.arn}",
  "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]

  github_project  = "Guardsman-cyber-intel/terraform-aws-iam-sleuth" #TODO: fork this project as well, 2nd fork 
  github_filename = "deployment.zip"
  github_release  = "v1.0.10"

  validation_sha = "280b88b3569dbb51711879e49325a88599739010" #TODO: get sha to validate here. (done)

  source_types = ["events"]
  source_arns  = ["${aws_cloudwatch_event_rule.sleuth_lambda_rule_trigger.arn}"]

  env_vars = {
    ENABLE_AUTO_EXPIRE  = "false"
    EXPIRATION_AGE      = 90
    WARNING_AGE         = 50
    EXPIRE_NOTIFICATION_TITLE           = "Key Rotation Instructions"
    EXPIRE_NOTIFICATION_TEXT            = "Please run.\n ```aws-vault rotate AWS-PROFILE```"
    INACTIVITY_AGE       = 30
    INACTIVITY_WARNING_AGE = 20
    INACTIVE_NOTIFICATION_TITLE         = "Key Usage Instructions to prevent key auto-disable"
    INACTIVE_NOTIFICATION_TEXT          = "Please run.\n ```aws-vault login AWS-PROFILE```"
    SLACK_URL           = data.aws_ssm_parameter.slack_url.value
    SNS_TOPIC           = ""
  }

  resource "sleuth_trigger" "key_rotation" {
    
    name = "key_rotation"

    tags = {
      SlackID      = "U03TY9ZBKDG"
      "Service" = "iam_sleuth"
    }
  }
}