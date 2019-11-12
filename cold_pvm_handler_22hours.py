from pprint import pprint
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from datetime import timedelta, datetime
import math
import pytz
import requests

credentials = GoogleCredentials.get_application_default()
service = discovery.build('compute', 'v1', credentials=credentials)

# Project ID for this request.
project = 'viewership-lift-and-shift-poc'  # TODO: Update placeholder value.

# The name of the zone where the managed instance group is located.

for i in range(1,103,1):
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
  instance_full_name=instances[0]["instance"]
  pprint(instance_full_name)
  lis = instance_full_name.split("/")
  instance_name=lis[-1] 
  pprint(instance_group_manager + ":" + status)
  
  request = service.instances().get(project=project, zone=zone, instance=instance_full_name)
  response = request.execute()
  
  # get VM creation time
  creation_time = response["creationTimestamp"]
  #creation_timestamp = datetime.timestamp(creation_time)
  #creation_timestamp = math.floor(creation_timestamp)
  
  # get current date and time
  datetimeFormat = '%Y-%m-%dT%H:%M:%S.%f-08:00'
  now = datetime.now(pytz.timezone('US/Pacific'))
  d = now.strftime("%d")
  m = now.strftime("%m")
  y = now.strftime("%Y")
  m1 = now.strftime("%M")
  h = now.strftime("%H")
  s = now.strftime("%S")
  current_time = y + "-" + m + "-" + d + "T"+ h + ":" + m1 + ":" + s+ "." + "000"+ "-08:00"
  
  # get difference in time
  diff = datetime.strptime(current_time, datetimeFormat) - datetime.strptime(creation_time, datetimeFormat)
  #print("Difference:", diff)
  #print("Days:", diff.days)
  #print("Microseconds:", diff.Microseconds)
  print("Creation time vs Current time difference in seconds:", diff.seconds)
  
  # get instance IP
  
  ip = response["networkInterfaces"][0]["networkIP"]
  url = ip + ':8082' 
  r = requests.get(url)
  r.json() # curl result healthcheck
  print(r)
  r = str(r)
  if (r == "<Response [200]>"):
  print("server is up")
  
""" 
  if (status != "RUNNING"):
    size1 = 2
    size2 = 1
    print("resizing" + instance_group_manager + " to 2")
    request = service.instanceGroupManagers().resize(project=project, zone=zone, instanceGroupManager=instance_group_manager, size=size1)
    response = request.execute()
    print("deleting old VM in MIG")
    request = service.instances().delete(project=project, zone=zone, instance=instance_name)
    response = request.execute()
    print("resizing" + instance_group_manager + "back to 1")
    request = service.instanceGroupManagers().resize(project=project, zone=zone, instanceGroupManager=instance_group_manager, size=size2)
    response = request.execute()

  else:
    print("It's working fine")
    
"""

#zone = 'asia-south1-a'  # TODO: Update placeholder value.
