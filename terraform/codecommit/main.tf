# DEPRECATED: source control migrated to GitHub in v1.0.1.

resource "aws_codecommit_repository" "repo" {
  repository_name = "${var.name}-codecommit-repo"
}
