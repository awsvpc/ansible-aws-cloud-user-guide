import boto3

def get_instance_ids_for_load_balancer(load_balancer_arn):
    elb_client = boto3.client('elbv2')

    instance_ids = []

    # Describe target groups for the load balancer
    target_groups_response = elb_client.describe_target_groups(LoadBalancerArn=load_balancer_arn)

    # For each target group, describe targets to get instance IDs
    for target_group in target_groups_response['TargetGroups']:
        targets_response = elb_client.describe_target_health(TargetGroupArn=target_group['TargetGroupArn'])
        for target in targets_response['TargetHealthDescriptions']:
            instance_ids.append(target['Target']['Id'])

    return instance_ids

def list_load_balancers_with_instances():
    elb_client = boto3.client('elbv2')

    # Describe all the load balancers
    load_balancers_response = elb_client.describe_load_balancers()

    for load_balancer in load_balancers_response['LoadBalancers']:
        load_balancer_name = load_balancer['LoadBalancerName']
        load_balancer_arn = load_balancer['LoadBalancerArn']
        load_balancer_type = load_balancer['Type']

        print(f"Load Balancer Name: {load_balancer_name}")
        print(f"Load Balancer ARN: {load_balancer_arn}")
        print(f"Load Balancer Type: {load_balancer_type}")

        # Get the instance IDs associated with this load balancer
        instance_ids = get_instance_ids_for_load_balancer(load_balancer_arn)
        print("Instance IDs associated:")
        for instance_id in instance_ids:
            print(instance_id)

        print("")

if __name__ == "__main__":
    list_load_balancers_with_instances()
