# zapr

###### This repository contains all the scripts used in infra provisioning for Zapr.

###### Provisioning scripts

__cold_cluster_scaler_existing_and_new_ssd.sh__: This is the script for provisioning & scaling up of cold cluster VMs. It takes following inputs.


| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| Start         | eg: 1         | The start number of the instances	|
| End           | eg: 103       | The end number of the instances	|
| type		| --preemptible or " "  | This value is case-sensitive. |
| option | true/True or false | If the disk are new: True; else false |


__cold-startup-script-new-disk.sh__: This is the startup script that cold_cluster_scaler_ssd_existing_v2.sh uses for new disks.

__cold-startup-script-existing-disk.sh__: This is the startup script that cold_cluster_scaler_ssd_existing_v2.sh uses  for existing disks.

__hot_cluster_scaler_parallel.sh__: This is the script for provisioning and scaling of hot cluster VMs parallely.

__hot-startup-script.sh__: This is the startup script that the hot_cluster_scaler_parallel.sh uses.

__path_manual.sh__: This is the script which sets the path rules for 103 cold cluster VMs. (It is static fixed to create the                       rules for 103 clusters.

###### Deletion Scripts

__cold_destroyer.sh__: This script tears down the cold setup (scales down cold cluster VMs from x to 0). 

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| upper         | eg: 103        | The current number of the instances.	|
| lower           | eg: 1     | The last instance group you want to delete. |

*For example: Upper = 103, lower = 2 will scale down to 1 vm.*

__hot_cluster_deleter.sh__: This is the script for scaling down hot cluster VMs.

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| start         | eg: 103        | The current number of the instances.	|
| end           | eg: 1     | The last instance group you want to delete. |

###### Managed instance group (MIG) resizing scripts.

__cold_mig_resize_0.sh:__ 

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| Total         | eg: 103        | 103 MIGs resizes to 0 VMs	|

*This assumes the lower limit to be 1, and hence applies changes to all of the MIGs from 1 to **total.***

__cold_mig_resize_1.sh:__ 

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| Total         | eg: 103        | 103 MIGs resizes to 1 VMs	|

*This assumes the lower limit to be 1, and hence applies changes to all of the MIGs from 1 to **total.***

__hot_mig_resize_0.sh:__ 

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| Total         | eg: 103        | 103 MIGs resizes to 0 VMs	|

*This assumes the lower limit to be 1, and hence applies changes to all of the MIGs from 1 to **total.***

__hot_mig_resize_1.sh:__ 

| Inputs        | Example       | Description				|
| ------------- | ------------- |---------------------------------------|
| Total         | eg: 103        | 103 MIGs resizes to 1 VMs	|

*This assumes the lower limit to be 1, and hence applies changes to all of the MIGs from 1 to **total.***

###### Preemption Handling scripts.

__cold_pvm_handler_22hours_parallel.py:__ Python script for resizing cold VMs older than 22 hours

__cold_pvm_handler_22hours_parallel.sh:__ Bash script which allows cold_pvm_handler_22hours_parallel.py to run in parallel. This is the script that needs to be run for preemption handling

__cold_pvm_handler_22hours_sequential.py *(Deprecated)*:__ Python script for resizing cold VMs older than 22 hours in sequential order.

__hot_preemption_handler_sequential.py:__ Python script for resizing hot VMs older than 22 hours in sequential order

###### Miscellaneous Scripts

__get_health.sh:__ checks the health of hot and cold backend services.

__router-config-properties-script.sh__: This is the sript uses that creates the url addresses that can be copy pasted into the                                         router config file.


###### C O M M A N D S 

1.  To check the size of the file downloaded in instance in human readable (-h) form, along with the last moification time (--time), use this command:
	`du -h --time <file name>`
	
###### M E T R I C E S

