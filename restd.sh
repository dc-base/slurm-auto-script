hostname=$(hostname -f)
openapi="v0.0.39"

echo $hostname

sudo chown $hostname:$hostname /var/run/slurmresd/
