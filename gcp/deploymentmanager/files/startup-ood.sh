#!/bin/bash -xe

sed -i "s|SELINUX=enforcing|SELINUX=permissive|g" /etc/selinux/config
setenforce 0

echo "ohpc-controller:/home /home nfs nfsvers=3,nodev,nosuid 0 0" >> /etc/fstab
echo "ohpc-controller:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> /etc/fstab
sleep 60
mount -a
# su - centos -c "ssh-keygen -q -t rsa -N '' <<< ""$'\n'"y" 2>&1 >/dev/null"
# su - centos -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
cp /home/.slurmconf /etc/slurm/slurm.conf
cp /home/.munge /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
systemctl start munge
systemctl enable munge

htpasswd -b -c /etc/httpd/.htpasswd sfd ood
systemctl enable httpd
mkdir /etc/ood/config/clusters.d
HEADER="Metadata-Flavor:Google"
URL="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
wget -nv --header $HEADER $URL/ood_ohpc -O /etc/ood/config/clusters.d/ohpc.yml
wget -nv --header $HEADER $URL/ood_portal -O /etc/ood/config/ood_portal.yml
/opt/ood/ood-portal-generator/sbin/update_ood_portal
systemctl start httpd
# reboot
