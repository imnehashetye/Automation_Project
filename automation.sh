sudo apt update -y
echo "update complete"
REQUIRED_PKG="apache2"
s3_bucket=""
my_name="Neha"
TIMESTAMP=$(date '+%d%m%Y-%H%M%S')
echo "TIMESTAMP $TIMESTAMP"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
ARCHIVED_FILE_NAME="$my_name-httpd-logs-$TIMESTAMP.tar"
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi
echo "checking if $REQUIRED_PKG is running"
status=$(sudo systemctl status $REQUIRED_PKG|grep running)
echo "status $status"
if [ "$status" != "" ]; then
  echo "$REQUIRED_PKG is running"
else
  echo "$REQUIRED_PKG is inactive, enabling it"
  sudo systemctl start $REQUIRED_PKG
  sudo systemctl is-active $REQUIRED_PKG
fi
echo "checking if $REQUIRED_PKG is enabled to start on reboot"
SERVICE_MODE=$(sudo systemctl is-enabled $REQUIRED_PKG.service)
echo "service_mode" $SERVICE_MODE
if [ "$SERVICE_MODE" == "enabled" ]; then
  echo "$REQUIRED_PKG will start automatically on reboot"
else
  echo "$REQUIRED_PKG is disabled, enabling it"
  sudo systemctl enable $REQUIRED_PKG.service
  sudo systemctl is-enabled $REQUIRED_PKG
fi
echo "Archiving log files starts"
sudo tar -cf /tmp/$ARCHIVED_FILE_NAME /var/log/$REQUIRED_PKG/*.log
echo "Archiving complete"

echo "Storing archiving log files to S3"
aws s3 cp /tmp/$ARCHIVED_FILE_NAME s3://$s3_bucket/$ARCHIVED_FILE_NAME
echo "Uploaded files to S3"

size=$(aws s3 ls s3://$s3_bucket/$ARCHIVED_FILE_NAME|awk '{print $3}')
echo "size $size"

file_path="/var/www/html"
inventory_file="inventory.html"

if [ -f "$file_path/$inventory_file" ]; then
    echo "$inventory_file exist."
    echo "httpd-logs            $TIMESTAMP              tar             $size" | sudo tee -a $file_path/$inventory_file
else
  echo "$inventory_file does not exist."
  sudo touch $file_path/$inventory_file
  echo "$inventory_file created."
  echo "Log Type                Time Created            Type            Size" | sudo tee -a $file_path/$inventory_file
  echo "httpd-logs            $TIMESTAMP              tar             $size" | sudo tee -a $file_path/$inventory_file
fi

echo "cron file check"
cron_file_path="/etc/cron.d"
cron_file="automation"

if [ -f "$cron_file_path/$cron_file" ]; then
    echo "$cron_file exist."
    cat $cron_file_path/$cron_file
else
  echo "$cron_file does not exist."
  sudo touch $cron_file_path/$cron_file
  echo "$cron_file created."
  echo "0 0 * * * root /root/Automation_Project/automation.sh" | sudo tee -a $cron_file_path/$cron_file
  cat $cron_file_path/$cron_file
fi
