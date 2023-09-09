resource "google_pubsub_topic" "topic" {
  name = "instance-scheduler-topic"
}

resource "google_cloud_scheduler_job" "cr_job" {
  name        = "instance-scheduler"
  description = "Cloud Scheduler to turn off labeled VMs."
  schedule    = var.cron_pattern

  pubsub_target {
    topic_name = google_pubsub_topic.topic.id
    data       = base64encode("foo, bar..")
  }
}

resource "google_storage_bucket" "bucket" {
  name = var.scheduler_function_bucket
}