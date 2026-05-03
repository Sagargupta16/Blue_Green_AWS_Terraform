################################################################################
# Root data.tf
################################################################################

# Current account (used by the iam module to build account-scoped resource ARNs).
data "aws_caller_identity" "current" {}
