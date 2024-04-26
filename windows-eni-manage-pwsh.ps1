## Method 1
# Import the AWS PowerShell module
Import-Module AWSPowerShell

# Define the region where your EC2 instance is located
$region = "us-east-1"  # Change this to your actual region

# Retrieve the instance ID of your EC2 instance
$instanceId = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/instance-id).Content

# Retrieve the details of attached ENIs for the instance
$attachedEnis = Get-EC2InstanceAttribute -InstanceId $instanceId -Attribute 'networkInterface'

# Extract the relevant details from each attached ENI
$eniDetails = @()
foreach ($eni in $attachedEnis.NetworkInterfaces) {
    $eniDetails += @{
        'AttachmentId' = $eni.Attachment.AttachmentId
        'ENIID' = $eni.NetworkInterfaceId
        'VpcId' = $eni.VpcId
        'SubnetId' = $eni.SubnetId
        'PrivateIpAddress' = $eni.PrivateIpAddress
        'AvailabilityZone' = $eni.AvailabilityZone
        # Add more properties as needed
    }
}

# Output the details of attached ENIs
$eniDetails


## Method 2
# Define the initial dictionary
$eni1 = @{
    'mgmt' = @{
        'az' = 'us-east-1a'
        'subnetid' = 'subnet-12345678'
        'vpcid' = 'vpc-12345678'
        'idx' = '1'
        'gw' = '10.0.0.1'
        'cidr' = '10.0.0.0/24'
        'ip' = '10.0.0.100'
    }
    'func' = @{
        'vpcid' = 'vpc-12345678'
        'idx' = '1'
        'gw' = '10.0.1.1'
        'cidr' = '10.0.1.0/24'
        'ip' = '10.0.1.100'
    }
}

# Check if eni is 1, if so, use 'func' instead of 'mgmt'
if ($eni1.Count -eq 1) {
    $eni2 = @{
        'func' = @{
            'vpcid' = 'vpc-12345678'
            'idx' = '2'
            'gw' = '10.0.2.1'
            'cidr' = '10.0.2.0/24'
            'ip' = '10.0.2.100'
        }
    }
}

# Add second eni to AWS EC2
# Add your AWS EC2 commands here

# Get the values again
# Add your commands to retrieve values from AWS EC2 here

# Combine both eni dictionaries
if ($eni2) {
    $combinedEni = $eni1 + $eni2
} else {
    $combinedEni = $eni1
}

# Print the list of values
$combinedEni.GetEnumerator() | ForEach-Object {
    Write-Output "Key: $($_.Key), Value: $($_.Value)"
}
