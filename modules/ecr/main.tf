resource "aws_ecr_repository" "repo-requests" {
  name = var.ecr_repository_name_requests
}

resource "aws_ecr_repository" "repo-payments" {
  name = var.ecr_repository_name_payments
}

resource "aws_ecr_repository" "repo-users" {
  name = var.ecr_repository_name_users
}
