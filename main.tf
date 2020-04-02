locals {
  # helper for assembly group => users
  groups = distinct(flatten([
    for user, attribute in var.users:
    try(attribute.groups, [])
  ]))

  # helper for assembly group => users
  user_group_normalization = {
    for user, attribute in var.users:
    user => try(attribute.groups, [])
  }

  # Crate map of groups with their user association
  group_membership = {
    for group in local.groups:
    group => [
      for user_name, user_groups in local.user_group_normalization:
      user_name
      if contains(user_groups, group)
    ]
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
  tags                 = merge(
    module.label.tags,
    lookup(each.value, "additional_tags", {})
  )
}

resource "aws_iam_access_key" "this" {
  for_each = {
    for user, attributes in var.users:
    user => attributes
    if lookup(attributes, "access_key_enabled", false)
  }

  user       = each.key
  pgp_key    = each.value.pgp_key
  status     = lookup(each.value, "access_key_status", null)

  depends_on = [
    aws_iam_user.this
  ]
}

resource "aws_iam_user_login_profile" "this" {
  for_each = {
    for user, attributes in var.users:
    user => attributes
    if lookup(attributes, "login_enabled", false)
  }

  user                    = each.key
  pgp_key                 = each.value.pgp_key
  password_length         = lookup(each.value, "password_length", null)
  password_reset_required = lookup(each.value, "password_reset_required", null)

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
    for user, attributes in var.users:
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
    for user, attributes in var.users:
    user => attributes
    if lookup(attributes, "policy_arn", false)
  }

  user       = each.key
  policy_arn = each.value.policy_arn

  depends_on = [
    aws_iam_user.this
  ]
}

resource "aws_iam_group_membership" "this" {
  for_each = local.group_membership

  name  = format("%s-%s", module.label.id, each.key)
  group = each.key
  users = each.value

  depends_on = [
    aws_iam_user.this
  ]
}