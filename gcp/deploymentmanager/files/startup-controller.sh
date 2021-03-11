#!/bin/bash -xe
exec > >(tee /var/log/startup.log|logger -t user-data -s 2>/dev/console) 2>&1
sed -i "s|SELINUX=enforcing|SELINUX=permissive|g" /etc/selinux/config
setenforce 0
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl restart nfs-server
systemctl enable nfs-server

HEADER="Metadata-Flavor:Google"
URL="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
wget -nv --header $HEADER $URL/slurm_conf -O /etc/slurm/slurm.conf
wget -nv --header $HEADER $URL/slurm_resume -O /etc/slurm/slurm-gcp-startup.sh
wget -nv --header $HEADER $URL/slurm_suspend -O /etc/slurm/slurm-gcp-shutdown.sh
wget -nv --header $HEADER $URL/slurm_compute_startup -O /etc/slurm/slurm-compute-startup.sh
wget -nv --header $HEADER $URL/gcp_instance -O /etc/slurm/gcp_instance.py
chmod +x /etc/slurm/slurm-gcp-startup.sh
chmod +x /etc/slurm/slurm-gcp-shutdown.sh
chmod +x /etc/slurm/slurm-compute-startup.sh
chmod +x /etc/slurm/gcp_instance.py
chown slurm:slurm /etc/slurm
systemctl start munge
systemctl enable munge
cp /etc/munge/munge.key /home/.munge
systemctl start slurmctld
systemctl enable slurmctld
cp /etc/slurm/slurm.conf /home/.slurmconf
touch /etc/slurm/power_save.log
chown slurm:slurm /etc/slurm/power_save.log
systemctl start x2gocleansessions
systemctl enable x2gocleansessions

pip3 install --upgrade pyyaml requests google-api-python-client
