from pprint import pprint
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

credentials = GoogleCredentials.get_application_default()
service = discovery.build('compute', 'v1', credentials=credentials)

# Project ID for this request.
project = 'viewership-lift-and-shift-poc'  # TODO: Update placeholder value.

# The name of the zone where the managed instance group is located.

for i in range(103):
  if(i%3 == 1):
  	zone = 'asia-south1-a'
  elif(i%3 == 2):
    zone = 'asia-south1-b'
  elif(i%3 == 0):
    zone = 'asia-south1-c'
  else:
    break
  instance_group_manager = 'cold-group-' + str(i)
  request = service.instanceGroupManagers().listManagedInstances(project=project, zone=zone, instanceGroupManager=instance_group_manager)
  response = request.execute()
  instances = response["managedInstances"]
  status=instances[0]["instanceStatus"]
  pprint(instance_group_manager + ":" + status)
#  if (status == "TERMINATED"):
#  	
#  else:
#    break

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
