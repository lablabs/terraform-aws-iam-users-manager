# Resource names will be computed: {namespace}-{environment}
variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "users" {
  description = "Map of the IAM users to be created with additional resources"
  type        = any

  # Expected value for the `users` is a map of users. The map key is the name of the user and
  # the value is another map with several optional keys:
  #
  # - path:
  #   (Optional, default "/") Path in which to create the user
  #
  # - permissions_boundary:
  #   (Optional) The ARN of the policy that is used to set the permissions boundary for the user
  #
  # - additional_tags:
  #   (Optional) Additional key-value mapping of tags for the IAM user
  #
  # - pgp_key:
  #    Either a base-64 encoded PGP public key, or a keybase username in the form keybase:some_person_that_exists, for use in the encrypted_secret output attribute.
  #    Required only when access_key_enabled or login_enabled are enabled.
  #
  # - access_key_enabled:
  #   (Optional, default false) Provides access key generation, pgp_key must be specified when enabled.
  #
  # - access_key_status:
  #   (Optional, default active) The access key status to apply. Valid values are Active and Inactive.
  #
  # - login_enabled:
  #   (Optional, default false) Provides passowrd generation, pgp_key must be specified when enabled.
  #
  # - login_password_length:
  #   (Optional, default 20) The length of the generated password on resource creation. Only applies on resource creation. Drift detection is not possible with this argument.
  #
  # - login_reset_required:
  #   (Optional, default "true") Whether the user should be forced to reset the generated password on resource creation. Only applies on resource creation. Drift detection is not possible with this argument.
  #
  # - ssh_key_enabled:
  #   (Optional, default false) Uploads an SSH public key and associates it with the specified IAM user.
  #
  # - ssh_key_encoding:
  #   Specifies the public key encoding format to use in the response. To retrieve the public key in ssh-rsa format, use SSH. To retrieve the public key in PEM format, use PEM.
  #   Required only when ssh_key_enabled is enabled.
  #
  # - ssh_public_key:
  #   The SSH public key. The public key must be encoded in ssh-rsa format or PEM format.
  #   Required only when ssh_key_enabled is enabled.
  #
  # - ssh_key_status:
  #   (Optional, default active) The status to assign to the SSH public key. Active means the key can be used for authentication with an AWS CodeCommit repository. Inactive means the key cannot be used.
  #
  # - policy_arn:
  #   (Optional, default []) Attaches a Managed IAM Policy to an IAM user.
  #
  # - groups:
  #   (Optional, default []) The IAM Group name to attach the list of users to.
  #
  #
  # Example:
  #
  # users = {
  #   foo = {
  #     login_enabled         = true
  #     pgp_key               = "LS0...S0tCg=="
  #     login_password_length = 32
  #     groups                = ["group1"]
  #   },
  #   bar = {}
  # }
  #
  # admin-2:
  #   Generate public key:
  #     gpg --gen-key
  #     gpg --export admin-2 | base64 -w 0
  #     echo "wcBMA7bO5IrA..." | base64 --decode | gpg -dq

}

variable "user_force_destroy" {
  description = "When destroying user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed."
  type        = bool
  default     = false
}
