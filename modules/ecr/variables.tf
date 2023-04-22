variable "repo_name" {}

variable "repo_pull_permissions" {
    type = list(string)
}

variable "repo_push_permissions" {
    type = list(string)
}