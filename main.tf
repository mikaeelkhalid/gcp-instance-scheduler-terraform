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

resource "google_storage_bucket_object" "archive" {
  name   = "function.zip"
  bucket = google_storage_bucket.bucket.name
  source = "gcp_function/function.zip"
}

resource "google_service_account" "svc_acc" {
  account_id   = "instance-scheduler-svc-acc"
  display_name = "instance-scheduler-svc-acc"
}

resource "google_project_iam_custom_role" "svc_acc_custom_role" {
  role_id     = "instance.scheduler"
  title       = "Instance Scheduler Role"
  description = "Ability to turn off instances with a specific label."
  permissions = [
    "compute.instances.list",
    "compute.instances.stop",
    "compute.zones.list",
  ]
}

resource "google_project_iam_member" "svc_acc_iam_member" {
  project = var.gcp_project
  role    = "projects/${var.project}/roles/${google_project_iam_custom_role.svc_acc_custom_role.role_id}"
  member  = "serviceAccount:${google_service_account.svc_acc.email}"

  depends_on = [
    google_service_account.svc_acc
  ]
}

resource "google_cloudfunctions_function" "instance_scheduler_function" {
  name                  = "instance-scheduler-function"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  runtime               = "python38"
  description           = "Cloud function to do the instance scheduling."

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic.name
    failure_policy {
      retry = false
    }
  }

  timeout               = 180
  entry_point           = "instance_scheduler_start"
  service_account_email = google_service_account.svc_acc.email

  environment_variables = {
    PROJECT     = var.gcp_project
    LABEL_KEY   = var.label_key
    LABEL_VALUE = var.label_value
  }
  depends_on = [
    google_service_account.svc_acc
  ]
}