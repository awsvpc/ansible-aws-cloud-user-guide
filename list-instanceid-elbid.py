import boto3

def get_load_balancers_for_instances(instance_ids):
    # Initialize the AWS SDK
    ec2_client = boto3.client('ec2')
    elb_client = boto3.client('elbv2')

    # Describe instances to get their associated network interfaces
    instance_descriptions = ec2_client.describe_instances(InstanceIds=instance_ids)

    # Extract network interface IDs from the instance descriptions
    network_interface_ids = []
    for reservation in instance_descriptions['Reservations']:
        for instance in reservation['Instances']:
            for interface in instance['NetworkInterfaces']:
                network_interface_ids.append(interface['NetworkInterfaceId'])

    # Describe load balancers to find those associated with the network interfaces
    load_balancer_arns = set()
    for network_interface_id in network_interface_ids:
        response = elb_client.describe_load_balancers(PageSize=400)
        for lb in response['LoadBalancers']:
            for target_group_arn in lb['TargetGroups']:
                targets = elb_client.describe_target_health(TargetGroupArn=target_group_arn)
                for target in targets['TargetHealthDescriptions']:
                    if target['Target']['Id'] == network_interface_id:
                        load_balancer_arns.add(lb['LoadBalancerArn'])

    # Describe load balancers by ARN to get more information if needed
    load_balancers = []
    for load_balancer_arn in load_balancer_arns:
        lb_info = elb_client.describe_load_balancers(LoadBalancerArns=[load_balancer_arn])
        load_balancers.append(lb_info['LoadBalancers'][0])

    return load_balancers

# Example usage
instance_id_list = ['instance-id-1', 'instance-id-2', 'instance-id-3']
load_balancers = get_load_balancers_for_instances(instance_id_list)
for lb in load_balancers:
    print("Load Balancer Name:", lb['LoadBalancerName'])
    print("Load Balancer ARN:", lb['LoadBalancerArn'])
    # Add more attributes as needed
