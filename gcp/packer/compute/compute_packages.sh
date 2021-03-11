#!/bin/bash

dnf -y update
dnf -y config-manager --set-enabled powertools
dnf -y install epel-release
dnf -y install http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
dnf -y install ohpc-base
dnf -y install ohpc-release
dnf -y install ohpc-slurm-client
dnf -y install wget curl python3-pip jq git make nfs-utils libnfs

# more recent version of podman
dnf -y module disable container-tools
dnf -y install 'dnf-command(copr)'
dnf -y copr enable rhcontainerbot/container-selinux
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
dnf -y install podman
