#!/bin/bash

sudo apt --assume-yes update
sudo apt --assume-yes upgrade

sudo apt --assume-yes install munge libmunge2 libmunge-dev

munge_status=$(munge -n | unmunge | grep STATUS)
munge_check="${munge_status^^}"

if [[ $munge_check == *"SUCCESS"* ]]; then
    echo "Munge OK"
fi

if ! [ -f /etc/munge/munge.key ]; then
    echo "Creating munge key"
    sudo /usr/sbin/mungekey
fi

sudo chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/
sudo chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/
sudo chmod 0755 /run/munge/
sudo chmod 0700 /etc/munge/munge.key
sudo chown -R munge: /etc/munge/munge.key

systemctl enable munge
systemctl restart munge

if ! systemctl is-active --quiet "munge.service" ; then
  echo "Munge is not running!!!"
  echo "Please check if munge is successfully installed and daemonized"
  exit 1
fi




