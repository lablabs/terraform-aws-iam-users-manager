output "user_names" {
  description = "List of IAM users names"
  value       = keys(aws_iam_user.this)
}

output "user_arns" {
  description = "Map of IAM users arn"
  value = {
    for user, value in aws_iam_user.this:
    user => value.arn
  }
}

output "user_uniq_ids" {
  description = "Map of IAM users uniq ids"
  value = {
    for user, value in aws_iam_user.this:
    user => value.unique_id
  }
}

output "user_paths" {
  description = "Map of IAM users path"
  value = {
    for user, value in aws_iam_user.this:
    user => value.path
  }
}

output "user_console_url" {
  description = "Console login url"
  value = local.login_url
}

output "user_access_attributes" {
  description = "Map of IAM users access key attributes"
  value = {
    for user, value in aws_iam_access_key.this:
    user => value
  } 
}

output "user_login_attributes" {
  description = "Map of IAM users login profile attributes"
  value = {
    for user, value in aws_iam_user_login_profile.this:
    user => value
  } 
}

output "user_ssh_attributes" {
  description = "Map of IAM users ssh key attributes"
  value = {
    for user, value in aws_iam_user_ssh_key.this:
    user => value
  } 
}

output "user_policy_attributes" {
  description = "Map of IAM users policy attachment attributes"
  value = {
    for user, value in aws_iam_user_policy_attachment.this:
    user => value
  } 
}