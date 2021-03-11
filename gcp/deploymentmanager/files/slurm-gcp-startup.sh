#!/bin/bash -il

export SLURM_ROOT=/etc/slurm
export SLURM_POWER_LOG=$SLURM_ROOT/power_save.log
export PATH=$PATH:/usr/local/bin:/usr/bin

function start_node()
{
    gcloud compute instances create $1 \
           --zone=us-west1-b \
           --machine-type=e2-standard-8 \
           --subnet=ohpc-us-west1 \
           --private-network-ip=$2 \
           --image=openhpc-compute-1615433350 \
           --image-project=tantrums-and-effusions \
           --boot-disk-size=170GB \
           --no-address \
           --metadata-from-file startup-script=/etc/slurm/slurm-compute-startup.sh \
           >> $SLURM_POWER_LOG 2>&1
}

function nametoip()
{
    n=$(echo $1 | cut -d "-" -f 3)
    echo 192.168.1.$n
}

echo "`date` Resume invoked $0 $*" >> $SLURM_POWER_LOG
hosts=$(scontrol show hostnames $1)
for hostname in $hosts
do
  private_ip=$(nametoip $hostname)
  # start_node $hostname $private_ip
  /etc/slurm/gcp_instance.py --action create --name $hostname --ipaddr $private_ip
  scontrol update nodename=$hostname nodehostname=$hostname nodeaddr=$private_ip
done
