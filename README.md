# GCP Instance Scheduler using Terraform

[![Mikaeel Khalid](https://badgen.now.sh/badge/by/mikaeelkhalid/purple)](https://github.com/mikaeelkhalid)

This project contains Terraform configurations and a Cloud Function in Python to schedule the shutdown of GCP VM instances based on specific labels.

For complete and detail explanations, please visit a blog [post](https://blog.mikaeels.com/gcp-instance-scheduler-using-terraform).

## Overview

The system works by:

1. A Cloud Scheduler job triggers a Cloud Function at specific times (set via a cron pattern).
2. The Cloud Function uses the GCP Compute API to:
   - List all zones in the project.
   - For each zone, list all VM instances with a specific label.
   - If the VM instance is running, it is shut down.

## Files Structure

- `gcp_function/main.py`: The Cloud Function script.
- `gcp_function/requirements.txt`: The Cloud Function dependencies.
- `main.tf`: Contains the main Terraform configurations for creating the necessary GCP resources.
- `provider.tf`: Sets the GCP provider and region.
- `variables.tf`: Defines the necessary variables for the Terraform configurations.
- `README.md`: Documentation

## Prerequisites

1. Google Cloud SDK installed and authenticated.
2. Terraform installed.

## Setup

1. Update the `variables.tf` with:

   - Your GCP project ID.
   - Your preferred cron pattern.
   - Your preferred storage bucket name for the Cloud Function archive.
   - Your preferred label key and value for targeted VM instances.

2. Package the Cloud Function:

   ```bash
   cd gcp_function
   zip -r function.zip *
   ```

3. Initialize Terraform and apply the configurations:

   ```bash
   terraform init
   terraform apply
   ```

4. Make sure to allow the required permissions for the created service account in the GCP Console.

## Usage

1. VM instances you want to be managed by the scheduler should have the specified label (default: `instance-scheduler=enabled`).
2. The Cloud Scheduler job will automatically trigger the Cloud Function based on the cron pattern you set.

## Customize

To use a different label or time, update the values in `variables.tf`.

For cron, you can use this website: https://crontab.guru

## Contributing

Feel free to raise issues or pull requests if you'd like to improve the configurations or add more features.

