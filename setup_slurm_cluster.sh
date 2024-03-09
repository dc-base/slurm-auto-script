#!/bin/bash

sudo apt --assume-yes update
sudo apt --assume-yes upgrade

sudo apt --assume-yes install munge libmunge2 libmunge-dev

export MUNGEUSER=1001
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge

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

echo "Done with munge setup"
#Create high permission slurm user
export SLURMUSER=1002
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

sudo apt --assume-yes install slurm-wlm
sudo apt --assume-yes install slurmrestd

#Modify slurm conf file with hostname
host=$(hostname -f)
sed -i "s/{SLURMHOST}/$host/g" ./config/slurm.conf
sudo cp -f ./config/slurm.conf /etc/slurm/slurm.conf
sudo mkdir /bin/mail
sudo apt-get --assume-yes install openmpi-bin openmpi-doc libopenmpi-dev

sudo touch /var/log/slurm/slurmd.log

sudo mkdir /var/spool/slurmd -p
sudo chown slurm: /var/spool/slurmd -f 
sudo chmod 755 /var/spool/slurmd -f
sudo mkdir /var/log/slurm/ -p
sudo touch /var/log/slurm/slurmd.log -f
sudo chown -R slurm:slurm /var/log/slurm/slurmd.log -f

# Start as systemd daemonized service
systemctl enable slurmctld
systemctl restart slurmctld

systemctl enable slurmd
systemctl restart slurmd

if ! systemctl is-active --quiet "slurmctld.service" ; then
  echo "Slurmctld is not running!!!"
  echo "Please check if Slurmctld is successfully installed and daemonized"
  exit 1
fi

if ! systemctl is-active --quiet "slurmd.service" ; then
  echo "Slurmd is not running!!!"
  echo "Please check if Slurmd is successfully installed and daemonized"
  exit 1
fi


