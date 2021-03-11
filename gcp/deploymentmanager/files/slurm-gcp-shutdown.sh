#!/bin/bash -il

export SLURM_ROOT=/etc/slurm
export SLURM_POWER_LOG=$SLURM_ROOT/power_save.log
export PATH=$PATH:/usr/local/bin:/usr/bin

function gcp_shutdown()
{
    gcloud compute instances delete $1 \
        --zone=us-west1-b --quiet \
    >> $SLURM_POWER_LOG 2>&1
}

echo "`date` Suspend invoked $0 $*" >> $SLURM_POWER_LOG
hosts=$(scontrol show hostnames $1)
for hostname in $hosts
do
   # gcp_shutdown $hostname
   /etc/slurm/gcp_instance.py --action delete --name $hostname
done
