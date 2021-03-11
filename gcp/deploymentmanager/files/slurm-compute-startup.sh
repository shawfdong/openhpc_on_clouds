#!/bin/bash -xe
exec > >(tee /var/log/startup.log|logger -t user-data -s 2>/dev/console) 2>&1
sed -i "s|SELINUX=enforcing|SELINUX=permissive|g" /etc/selinux/config
setenforce 0
# sleep 180
echo "ohpc-controller:/home /home nfs nfsvers=3,nodev,nosuid 0 0" >> /etc/fstab
echo "ohpc-controller:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> /etc/fstab
mount -a
cp /home/.munge /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
systemctl start munge
systemctl enable munge
cp /home/.slurmconf /etc/slurm/slurm.conf
echo SLURMD_OPTIONS="--conf-server ohpc-controller" > /etc/sysconfig/slurmd
systemctl restart slurmd
systemctl enable slurmd
