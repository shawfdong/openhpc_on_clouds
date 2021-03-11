#!/bin/bash


dnf -y update
dnf -y config-manager --set-enabled powertools
dnf -y install epel-release
dnf -y install http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
dnf -y install ohpc-base
dnf -y install ohpc-release
dnf -y install ohpc-slurm-server
dnf -y install lmod-ohpc
# dev packages
dnf -y install ohpc-autotools
dnf -y install EasyBuild-ohpc
dnf -y install hwloc-ohpc
dnf -y install spack-ohpc
dnf -y install valgrind-ohpc
# gnu9 serial/threaded packages
dnf -y install ohpc-gnu9-serial-libs
dnf -y install ohpc-gnu9-runtimes
dnf -y install hdf5-gnu9-ohpc
dnf -y install python3-numpy-gnu9-ohpc

# install gnu9/mpich and gnu9/openmpi package variants
dnf -y install ohpc-gnu9-mpich*
dnf -y install ohpc-gnu9-openmpi4*
dnf -y install lmod-defaults-gnu9-openmpi4-ohpc
dnf -y install wget curl python3-pip jq git make nfs-utils

# x2go + XFCE deps
dnf -y install  x2goserver x2goserver-xsession
dnf -y groupinstall "Xfce"
dnf -y groupinstall workstation

# more recent version of podman
dnf -y module disable container-tools
dnf -y install 'dnf-command(copr)'
dnf -y copr enable rhcontainerbot/container-selinux
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
dnf -y install podman
