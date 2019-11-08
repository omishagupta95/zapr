from pprint import pprint
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from datetime import timedelta, datetime
import math

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
  creation_timestamp = datetime.timestamp(creation_time)
  creation_timestamp = math.floor(creation_timestamp))
  # get current date and time
  now = datetime.now()
  current_timestamp = datetime.timestamp(now)
  current_timestamp = math.floor(current_timestamp))
  time_diff = current_timestamp - creation_timestamp
  print(time_diff)
  
  
  """
  THIS IS THE WORKIN SCRIPT
  datetimeFormat = '%Y-%m-%d %H:%M:%S.%f'
  now = datetime.now()
  d = now.strftime("%d")
  m = now.strftime("%m")
  y = now.strftime("%Y")
  m1 = now.strftime("%M")
  h = now.strftime("%H")
  s = now.strftime("%S")
  current_time = y + "-" + m + "-" + d + " "+ h + ":" + m1 + ":" + s+ "." + "000"
  diff = datetime.strptime(current_time, datetimeFormat) - datetime.strptime(creation_time, datetimeFormat)
  print("Difference:", diff)
  print("Days:", diff.days)
  #print("Microseconds:", diff.Microseconds)
  print("Seconds:", diff.seconds)
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

#zone = 'asia-south1-a'  # TODO: Update placeholder value.

"""
from pprint import pprint
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
import datetime
from datetime import timedelta, datetime
import math
from pytz import timezone
import pytz
import os, time
import math

os.environ['TZ'] = 'US/Pacific'

credentials = GoogleCredentials.get_application_default()
service = discovery.build('compute', 'v1', credentials=credentials)


# Project ID for this request.
project = 'viewership-lift-and-shift-poc'  # TODO: Update placeholder value.
zone = 'asia-south1-a'
instance_full_name = 'cold-instance-48h6'


request = service.instances().get(project=project, zone=zone, instance=instance_full_name)
response = request.execute()

now3 = datetime.now(pytz.timezone('US/Pacific'))
#print("Current time now in IST="+str(a))
print("Current time in PST="+str(now3))
datetimeFormat = '%Y-%m-%dT%H:%M:%S.%f-08:00'

d = now3.strftime("%d")
m = now3.strftime("%m")
y = now3.strftime("%Y")
m1 = now3.strftime("%M")
h = now3.strftime("%H")
s = now3.strftime("%S")

date2 = y + "-" + m + "-" + d + "T"+ h + ":" + m1 + ":" + s+ "." + "000"+ "-08:00"
print("Date_Time in PST string format =" + date2)

creation_time = response["creationTimestamp"]
print("Creation timestamp of VM="+ creation_time)

diff = datetime.strptime(date2, datetimeFormat)\
  - datetime.strptime(creation_time, datetimeFormat)
  
print("Diff in sec=", diff.seconds)

"""
