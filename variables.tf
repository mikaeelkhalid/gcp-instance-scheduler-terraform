variable "gcp_project" {
  default = "your gcp project_id here"
}

variable "cron_pattern" {
  default = "59 23 * * *" # set to every day, at 23:59
}

variable "scheduler_function_bucket" {
  default = "your bucket name here"
}