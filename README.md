# Automation_Project
# Automation_Project
Server installation bash script
1) Install the apache2 package if it is not already installed. (The dpkg and apt commands are used to check the installation of the packages.)

2) Ensure that the apache2 service is running.

3)Ensure that the apache2 service is enabled. (The systemctl or service commands are used to check if the services are enabled and running. Enabling apache2 as a service ensures that it runs as soon as our machine reboots. It is a daemon process that runs in the background.)

4)Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ directory and place the tar into the /tmp/ directory. Create a tar of only the .log files (for example access.log) and not any other file type (For example: .zip and .tar) that are already present in the /var/log/apache2/ directory.

5) The name of tar archive should have following format:  "<your _name>-httpd-logs-<timestamp>.tar". For example: "Neha-httpd-logs-01212021-101010.tar "

6)The script should run the AWS CLI command and copy the archive to the s3 bucket

# Script execution steps
Make the script executible
chmod  +x  /root/Automation_Project/automation.sh

switch to root user with sudo su
sudo  su
./root/Automation_Project/automation.sh

or run with sudo privileges
sudo ./root/Automation_Project/automation.sh
