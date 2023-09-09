variable "gcp_project" {
  default = "your gcp project_id here"
}

# set to every day, at 23:59
variable "cron_pattern" {
  default = "59 23 * * *"
}