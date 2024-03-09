# Steps to start up single node local slurm cluster

    sudo bash setup_slurm_cluster.sh

# To start slurmrestd
    sudo bash restd.sh
    . ./startrestd.sh


    Check is restd is up

    curl --unix-socket /var/run/restd.socket localhost/slurm/v0.0.39/ping

# Other tools
    Stop and disable daemonized processes
    ./teardown.sh