#!/bin/bash
systemctl stop slurmctld
systemctl stop munge
systemctl stop slurmd

systemctl disable slurmctld
systemctl disable munge
systemctl disable slurmd