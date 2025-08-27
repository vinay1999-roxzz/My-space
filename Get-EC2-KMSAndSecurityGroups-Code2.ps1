# Import the AWS PowerShell Module
Import-Module AWSPowerShell

# Set AWS Region (adjust as needed)
$Region = "us-east-1"

# Set EC2 Instance ID (replace with the target instance ID)
$InstanceId = "i-1234567890abcdef0"

# Retrieve EC2 instance metadata
$Instance = Get-EC2Instance -InstanceIds $InstanceId -Region $Region

# Extract instance details
$InstanceDetails = $Instance.Instances[0]

# Display Security Groups associated with the EC2 instance
$SecurityGroups = $InstanceDetails.SecurityGroups
Write-Host "Security Groups associated with the instance:"
foreach ($SG in $SecurityGroups) {
    Write-Host "  - Security Group Name: $($SG.GroupName), Group ID: $($SG.GroupId)"
}

# Check if the instance has associated volumes
$Volumes = $InstanceDetails.BlockDeviceMappings
if ($Volumes -eq $null) {
    Write-Host "No volumes are attached to the instance."
    return
}

# Loop through volumes to get KMS Key details
foreach ($Volume in $Volumes) {
    $VolumeId = $Volume.Ebs.VolumeId
    $VolumeInfo = Get-EC2Volume -VolumeIds $VolumeId -Region $Region

    # Check if the volume is encrypted
    if ($VolumeInfo.Volumes.Encrypted) {
        $KmsKeyId = $VolumeInfo.Volumes.KmsKeyId
        Write-Host "Volume ID: $VolumeId"
        Write-Host "KMS Key ID: $KmsKeyId"

        # Retrieve KMS Key ARN
        $KmsKey = Get-KMSKey -KeyId $KmsKeyId -Region $Region
        Write-Host "KMS Key ARN: $($KmsKey.KeyMetadata.Arn)"
    } else {
        Write-Host "Volume ID: $VolumeId is not encrypted."
    }
}
