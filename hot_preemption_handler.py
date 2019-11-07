from pprint import pprint
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

credentials = GoogleCredentials.get_application_default()
service = discovery.build('compute', 'v1', credentials=credentials)

# Project ID for this request.
project = 'viewership-lift-and-shift-poc'  # TODO: Update placeholder value.

# The name of the zone where the managed instance group is located.

for i in range(1,11,1):
  region = asia-south1
  instance_group_manager = 'hot-group-' + str(i)
  request = service.instanceGroupManagers().listManagedInstances(project=project, region=region, instanceGroupManager=instance_group_manager)
  response = request.execute()
  instances = response["managedInstances"]
  status=instances[0]["instanceStatus"]
  instance_full_name=instances[0]["instance"]
  pprint(instance_full_name)
  lis = instance_full_name.split("/")
  instance_name=lis[-1] 
  instance_zone=lis[-3] 
  pprint(instance_group_manager + ":" + status)
  if (status != "RUNNING"):
    size1 = 2
    size2 = 1
    print("resizing" + instance_group_manager + " to 2")
    request = service.instanceGroupManagers().resize(project=project, region=region, instanceGroupManager=instance_group_manager, size=size1)
    response = request.execute()
    print("deleting old VM in MIG")
    request = service.instances().delete(project=project, zone=instance_zone, instance=instance_name)
    response = request.execute()
    print("resizing" + instance_group_manager + "back to 1")
    request = service.instanceGroupManagers().resize(project=project, region=region, instanceGroupManager=instance_group_manager, size=size2)
    response = request.execute()

  else:
    print("It's working fine")

#zone = 'asia-south1-a'  # TODO: Update placeholder value.

"""
# The name of the managed instance group.
instance_group_manager = 'cold-group-1'  # TODO: Update placeholder value.
request = service.instanceGroupManagers().listManagedInstances(project=project, zone=zone, instanceGroupManager=instance_group_manager)
response = request.execute()
# TODO: Change code below to process the `response` dict:
instances = response["managedInstances"]
status=instances[0]["instanceStatus"]
pprint(status)
"""
