locals {
  user_groups = {
    for user, attribute in var.users :
    user => attribute.groups
    if length(lookup(attribute, "groups", [])) > 0 ? true : false
  }

  login_url = format("https://%s.signin.aws.amazon.com/console", data.aws_caller_identity.provider.account_id)
}

data "aws_caller_identity" "provider" {}

resource "aws_iam_user" "this" {
  for_each = var.users

  name                 = each.key
  path                 = lookup(each.value, "path", null)
  permissions_boundary = lookup(each.value, "permissions_boundary", null)
  force_destroy        = var.user_force_destroy
  tags = merge(
    module.label.tags,
    lookup(each.value, "additional_tags", {})
  )
}

resource "aws_iam_access_key" "this" {
  for_each = {
    for user, attributes in var.users :
    user => attributes
    if lookup(attributes, "access_key_enabled", false)
  }

  user    = each.key
  pgp_key = each.value.pgp_key
  status  = lookup(each.value, "access_key_status", null)

  depends_on = [
    aws_iam_user.this
  ]
}

resource "aws_iam_user_login_profile" "this" {
  for_each = {
    for user, attributes in var.users :
    user => attributes
    if lookup(attributes, "login_enabled", false)
  }

  user                    = each.key
  pgp_key                 = each.value.pgp_key
  password_length         = lookup(each.value, "login_password_length", null)
  password_reset_required = lookup(each.value, "login_reset_required", null)

  depends_on = [
    aws_iam_user.this
  ]

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

resource "aws_iam_user_ssh_key" "this" {
  for_each = {
    for user, attributes in var.users :
    user => attributes
    if lookup(attributes, "ssh_key_enabled", false)
  }

  username   = each.key
  encoding   = each.value.ssh_key_encoding
  public_key = each.value.public_key
  status     = lookup(each.value, "ssh_key_status", null)

  depends_on = [
    aws_iam_user.this
  ]
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for user, attributes in var.users :
    user => attributes
    if lookup(attributes, "policy_arn", false)
  }

  user       = each.key
  policy_arn = each.value.policy_arn

  depends_on = [
    aws_iam_user.this
  ]
}

resource "aws_iam_user_group_membership" "this" {
  for_each = local.user_groups

  user   = each.key
  groups = each.value
}
