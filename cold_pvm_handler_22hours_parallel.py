from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from datetime import timedelta, datetime
import math
import pytz
import logging
import requests
from pprint import pprint
import sys

credentials = GoogleCredentials.get_application_default()
service = discovery.build('compute', 'v1', credentials=credentials)

def test_request(i):
 logging.basicConfig(level=logging.INFO)
 logger = logging.getLogger(__name__)

# Project ID for this request.
 project = 'viewership-lift-and-shift-poc'  # TODO: Update placeholder value.

# The name of the zone where the managed instance group is located.

 if(i%3 == 1):
    zone = 'asia-south1-a'
 elif(i%3 == 2):
    zone = 'asia-south1-b'
 elif(i%3 == 0):
    zone = 'asia-south1-c'
 
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
 request = service.instances().get(project=project, zone=zone, instance=instance_name)
 response = request.execute()
 
 # get VM creation time
 creation_time = response["creationTimestamp"]
 #  creation_timestamp = datetime.timestamp(creation_time)
 #  creation_timestamp = math.floor(creation_timestamp)
  
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
 vm_age = diff.seconds

 if (vm_age >= 79200):
    size1 = 2
    print("resizing" + instance_group_manager + " to 2")
    request = service.instanceGroupManagers().resize(project=project, zone=zone, instanceGroupManager=instance_group_manager, size=size1)
    response = request.execute()
    check_health(project,zone,instance_group_manager,instance_name)

       

def check_health(project,zone,instance_group_manager,instance_name):

       request = service.instanceGroupManagers().get(project=project, zone=zone, instanceGroupManager=instance_group_manager)
       response = request.execute()
       pprint(response["status"]["isStable"])
       status = response["status"]["isStable"]
       status = str(status)
       size2 = 1

       if (status == "True"):
         print("New VM is healthy, deleting old VM")
         request = service.instances().delete(project=project, zone=zone, instance=instance_name)
         response = request.execute()
         print("resizing" + instance_group_manager + "back to 1")
         request = service.instanceGroupManagers().resize(project=project, zone=zone, instanceGroupManager=instance_group_manager, size=size2)
         response = request.execute()
       else:
         print("New VM is not healthy yet, checking status")
         check_health(project,zone,instance_group_manager,instance_name)
     


if __name__ == '__main__':
  i = sys.argv[1]
  i = int(i)
  test_request(i)

