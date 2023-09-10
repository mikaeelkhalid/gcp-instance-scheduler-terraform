import base64
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
import os

API_VERSION = 'v1'
RESOURCE_TYPE = 'compute'

def authenticate():
    try:
        credentials = GoogleCredentials.get_application_default()
        service = discovery.build(RESOURCE_TYPE, API_VERSION, credentials=credentials, cache_discovery=False)
        return service
    except Exception as error:
        return error

def gather_zones(project, service):
    try:
        zones = service.zones().list(project=project).execute()
        zone_list = [zone['name'] for zone in zones['items']]
        return zone_list
    except Exception as error:
        return error

def turn_instance_off(project, service, instance, zone):
    try:
        service.instances().stop(project=project, zone=zone, instance=instance).execute()
        print(f"Successfully turned off VM {instance} in project {project}, zone {zone}.")
    except Exception as error:
        return error

def locate_instances(project, service, zones, label_key, label_value):
    try:
        for zone in zones:
            instances = service.instances().list(project=project, zone=zone, filter=f"labels.{label_key}={label_value}").execute()
            if 'items' in instances:
                for instance in instances['items']:
                    if instance['status'] == "RUNNING":
                        turn_instance_off(project, service, instance['name'], zone)
    except Exception as error:
        return error

def instance_scheduler_start(event, context):

    project = os.environ.get('PROJECT')
    label_key = os.environ.get('LABEL_KEY')
    label_value = os.environ.get('LABEL_VALUE')

    service = authenticate()

    zones = gather_zones(project, service)

    locate_instances(project, service, zones, label_key, label_value)
