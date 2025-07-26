variable "name" {
    description = "The name of the CodeCommit repository that will store the application source code"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to CodeCommit repository for resource management and cost tracking"
    type        = map(string)
    default     = {}
}