#!/usr/bin/env python3

import argparse
import os
import time

import googleapiclient.discovery
from six.moves import input

# [START list_instances]
def list_instances(compute, project, zone):
    result = compute.instances().list(project=project, zone=zone).execute()
    return result['items'] if 'items' in result else None
# [END list_instances]

# [START create_instance]
def create_instance(compute, project, zone, name, ipaddr):
    # Get the latest Debian Jessie image.
    image_response = compute.images().get(
        project='tantrums-and-effusions', image='openhpc-compute-1615433350').execute()
    source_disk_image = image_response['selfLink']

    # Configure the machine
    machine_type = "zones/%s/machineTypes/e2-standard-8" % zone
    startup_script = open(
        os.path.join(
            os.path.dirname(__file__), 'slurm-compute-startup.sh'), 'r').read()

    config = {
        'name': name,
        'machineType': machine_type,

        # Specify the boot disk and the image to use as a source.
        'disks': [
            {
                'boot': True,
                'autoDelete': True,
                'diskSizeGb': '170',
                'initializeParams': {
                    'sourceImage': source_disk_image,
                }
            }
        ],

        # Specify a network interface with NAT to access the public
        # internet.
        'networkInterfaces': [{
            'network': 'projects/tantrums-and-effusions/global/networks/ohpc-network',
            'networkIP': ipaddr,
            'subnetwork': 'projects/tantrums-and-effusions/regions/us-west1/subnetworks/ohpc-us-west1'
        }],

        # Metadata is readable from the instance and allows you to
        # pass configuration from deployment scripts to instances.
        'metadata': {
            'items': [{
                # Startup script is automatically executed by the
                # instance upon startup.
                'key': 'startup-script',
                'value': startup_script
            }]
        }
    }

    return compute.instances().insert(
        project=project,
        zone=zone,
        body=config).execute()
# [END create_instance]


# [START delete_instance]
def delete_instance(compute, project, zone, name):
    return compute.instances().delete(
        project=project,
        zone=zone,
        instance=name).execute()
# [END delete_instance]


# [START wait_for_operation]
def wait_for_operation(compute, project, zone, operation):
    print('Waiting for operation to finish...')
    while True:
        result = compute.zoneOperations().get(
            project=project,
            zone=zone,
            operation=operation).execute()

        if result['status'] == 'DONE':
            print("done.")
            if 'error' in result:
                raise Exception(result['error'])
            return result

        time.sleep(1)
# [END wait_for_operation]


# [START run]
if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--project', 
        default='tantrums-and-effusions', 
        help='Your Google Cloud project ID.')
    parser.add_argument(
        '--zone',
        default='us-west1-b',
        help='Compute Engine zone to deploy to.')
    parser.add_argument(
            '--action', help='Action to take: create or delete.')
    parser.add_argument(
        '--name', help='Instance name.')
    parser.add_argument(
        '--ipaddr', help='IP address.')

    args = parser.parse_args()
    compute = googleapiclient.discovery.build('compute', 'v1')
    if args.action == 'create':
        operation = create_instance(compute, args.project, args.zone,args. name, args.ipaddr)
        wait_for_operation(compute, args.project, args.zone, operation['name'])
    elif args.action == 'delete':
        operation = delete_instance(compute, args.project, args.zone, args.name)
        wait_for_operation(compute, args.project, args.zone, operation['name'])
    else:
        pass
# [END run]
