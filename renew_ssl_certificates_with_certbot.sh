#!/bin/bash

PORT=8080

# Get the process ID and name associated with `PORT`
process_info=$(sudo lsof -i :$PORT -sTCP:LISTEN -t -n -P)

# if `PORT` is in use ask the user to stop the service running on it
if [ -n "$process_info" ]; then
    process_name=$(ps -p $process_info -o comm=)
    echo "Port $PORT is being used by the following service: $process_name"
    echo "If the script fails then stop the service above with the following command and rerun the script"
    echo "sudo systemctl stop ..."
    # Wait for the user to press a key
    #read -n1 -s
fi

# call certbot to renew the certificates
sudo certbot renew

# Set the working directory to /etc/apache2
cd /etc/apache2
# restore the original ports.conf file since certbot modifies it
sudo git checkout ports.conf
# restart apache to use the restored ports.conf file
sudo systemctl restart apache2
