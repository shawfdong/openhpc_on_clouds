# OpenHPC on AWS

Based on [PEARC 2020 Tutorial](https://openhpc.github.io/cloudwg/tutorials/pearc20/pearc20.html) for OpenHPC, written by Christopher Simmons (UT Dallas). 

## AWS CLI

```
aws configure list
```

Or you can use Cloud9

## EC2 Key Pair

In AWS Management Console, navigate to Services -> EC2 -> Key Pairs, then Create key pair.

## Building AMIs using Packer

If you haven't done so, install HarshiCorp Packer. On Mac

```
brew tap hashicorp/tap
brew install hashicorp/tap/packer

### verifying the installation
packer
```

Packer templates can be written in either HCL (Hashicorp Configuration Language) or JSON.

```
### building the compute AMI
cd /path/to/aws/packer/compute
packer build compute.json

### building the ood-login AMI
cd /path/to/aws/packer/ood-login
packer build ood-login.json

### building the x2go-controller AMI
cd /path/to/aws/packer/x2go-controller
packer build x2go-controller.json
```

## Deploying the cluster with CloudFormation

```
cd /path/to/aws/cloudformation
aws cloudformation deploy --template-file slurm-dynamic-ood-ohpc.yml --capabilities CAPABILITY_IAM --stack-name openhpc --region us-east-1
```

## Testing the cluster

SSH to X2goManagement

```
ssh -i ~/.ssh/openhpc.pem centos@ec2-18-207-44-135.compute-1.amazonaws.com

cp /opt/ohpc/pub/examples/mpi/hello.c .
mpicc hello.c
cp /opt/ohpc/pub/examples/slurm/job.mpi .
sbatch job.mpi
watch -n 10 squeue
```

## OOD

Open OnDemand 1.7

## Destroying the cluster

```
aws cloudformation delete-stack --stack-name openhpc
```
