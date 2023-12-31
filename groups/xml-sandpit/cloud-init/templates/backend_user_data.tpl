!/bin/bash
# Redirect the user-data output to the console logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Ensure ClamAV databases are cleaned and updated
/sbin/service clamd stop
/bin/rm -f /var/lib/clamav/*
/usr/bin/freshclam

#Create key:value variable
cat <<EOF >>inputs.json
${BACKEND_INPUTS}
EOF

#Create cron file and set crontab
cat <<EOF >>/root/cronfile
${BACKEND_CRON_ENTRIES}
EOF
crontab -u xml-sandpit /root/cronfile

#Set FESS_TOKEN
echo "export FESS_TOKEN=${FESS_TOKEN}" >> /home/xml-sandpit/.bash_profile

#Create the TNSNames.ora file for Oracle
/usr/local/bin/j2 -f json /usr/lib/oracle/11.2/client64/lib/tnsnames.j2 inputs.json > /usr/lib/oracle/11.2/client64/lib/tnsnames.ora

#Remove unnecessary files
rm /etc/httpd/conf.d/welcome.conf
rm /etc/httpd/conf.d/ssl.conf
rm /etc/httpd/conf.d/perl.conf

#Run Ansible playbook for Backend deployment using provided inputs
/usr/local/bin/ansible-playbook /root/backend_deployment.yml -e '${ANSIBLE_INPUTS}'

# Update hostname
INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/HOSTNAME=.*/HOSTNAME=$INSTANCEID/" /etc/sysconfig/network
sed -i "s/\b127.0.0.1\b/127.0.0.1 $INSTANCEID/" /etc/hosts

# Reboot to take effect
reboot
