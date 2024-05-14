# Define a dictionary variable to store metadata
$metadata = @{}

# Retrieve metadata from EC2 instance
Invoke-RestMethod -Uri 'http://169.254.169.254/latest/meta-data/' | ForEach-Object {
    $key = $_
    $value = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/$key"
    $metadata[$key] = $value
}

# Display the metadata
$metadata


Get-EC2InstanceMetadata
