################################################################################
# CodeCommit Module - main.tf
#
# DEPRECATED / UNUSED.
# Source control was migrated to GitHub (via a CodeStar Connection) in
# release 1.0.1. This module is no longer invoked from the root main.tf and
# is kept only for historical reference. It can be safely deleted once
# nobody relies on reading it.
################################################################################

resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.name}-codecommit-repo"
}
