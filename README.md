# Rubrik-Fileset-Backup

This script makes a fileset backup from a host via shell script. This was developed for a customer who needs to make a backup during a freeze time. 

### Requirements
- An API token must be created on the Rubrik
- Port 443 should be open from the VM to the Rubrik Cluster
- The Fileset should be created on Rubrik
- The Fileset should be assigned with the correct SLA Domain

### Important to know
The API Token can be only valid for maximum 365 days. You need to change the token every year. 

### Explanation	
The following fixed variables must be included:
- Rubrik IP or FQDN
- Host name from the VM, which needs the Fileset Backup

The fileset name, which is given in the curl command, is used to determine which fileset ID and which SLA ID have been assigned to the fileset in the CDM section.

Then it checks whether the host exists on the cluster. If not, the script is aborted. 

If all the information can be collected, the fileset backup can be started. The current status is always logged. 
