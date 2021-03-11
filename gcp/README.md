# OpenHPC on AWS

## Google Cloud SDK

```
gcloud config list
gcloud auth login
gcloud auth list
```

Or you can use Cloud Shell

## Public CentOS 8 Image

There is a public image: centos-8-v20210217. You can create a VM instance from that image:

```
gcloud compute instances create test-centos-8 \
    --zone=us-west1-b --machine-type=e2-medium \
    --image=centos-8-v20210217 --image-project=centos-cloud \
    --boot-disk-size=20GB

gcloud compute ssh test-centos-8

[sfd@test-centos-8 ~]$ id
[sfd@test-centos-8 ~]$ curl "http://metadata.google.internal/computeMetadata/v1/instance/" -H "Metadata-Flavor: Google"
[sfd@test-centos-8 ~]# sudo systemctl list-unit-files | grep google | grep enabled
[sfd@test-centos-8 ~]$ exit

gcloud compute instances delete test-centos-8
```

## Building images using Packer

We'll create new images based on the existing `centos-8-v20210217`, using the [googlecompute Packer builder](https://www.packer.io/docs/builders/googlecompute).

Authenticate using User Application Default Credentials:

```
gcloud auth application-default login
```

Packer templates can be written in either HCL (Hashicorp Configuration Language) or JSON.

```
### building the compute image
cd /path/to/gcp/packer/compute
packer build compute.json

### building the ood-login AMI
cd /path/to/gcp/packer/ood-login
packer build ood-login.json

### building the x2go-controller AMI
cd /path/to/gcp/packer/x2go-controller
packer build x2go-controller.json
```

Created images:

* openhpc-compute-1615433350
* openhpc-ood-login-1615435802
* openhpc-x2go-controller-1615436602

## Deploying the cluster with Deployment Manager

Enable the Deployment Manager and Compute Engine APIs.

```
cd /path/to/gcp/deploymentmanager
gcloud deployment-manager deployments create openhpc --config openhpc.yaml
```

* openhpc.yaml: configuration
* openhpc.jinja: template
* openhpc.jinja.schema: [schema](https://cloud.google.com/deployment-manager/docs/configuration/templates/using-schemas)

## Testing the cluster

SSH to x2go-controller

```
gcloud compute ssh ohpc-controller

cp /opt/ohpc/pub/examples/mpi/hello.c .
mpicc hello.c
cp /opt/ohpc/pub/examples/slurm/job.mpi .
sbatch job.mpi
watch -n 10 squeue
```

## OOD

Open OnDemand 1.8

```
gcloud compute ssh ohpc-ood
```

## Destroying the cluster

```
gcloud deployment-manager deployments delete openhpc
```
