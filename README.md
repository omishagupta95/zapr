# zapr

This repository contains all the scripts used in infra provisioning for Zapr.

cold_cluster_scaler_ssd_existing_v2.sh -> This is the script for provisioning & scaling up of cold cluster VMs when the                                                   underlying SSD disks already exist with the relevant kyoto files

cold-startup-script-existing-disk.sh -> This is the startup script that cold_cluster_scaler_ssd_existing_v2.sh uses.

path_manual.sh -> This is the script which sets the path rules for 103 cold cluster VMs. (It is static fixed to create the                       rules for 103 clusters.

cold_destroyer_v2.sh -> This script tears down the cold setup (scales down cold cluster VMs from x to 0).

router-config-properties-script.sh -> This is the sript uses that creates the url addresses that can be copy pasted into the                                         router config file.

hot_cluster_scaler.sh -> This is the script for provisioning and scaling of hot cluster VMs.

hot-startup-script.sh -> This is the startup script that the hot_cluster_scaler.sh uses.

hot_cluster_deleter.sh -> This is the script for scaling down hot cluster VMs.

--------------------------------- C O M M A N D S -------------------------------------

1.  To check the size of the file downloaded in instance in human readable (-h) form, along with the last moification time (--time), use this command:
	`du -h --time <file name>`

