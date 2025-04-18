param(
    [string]$InstanceId,
    [string]$Region = "us-east-1"
)

# .\Get-EC2-KMSAndSecurityGroups.ps1 -InstanceId i-0123456789abcdef0 -Region us-east-1
# Set region
Set-DefaultAWSRegion -Region $Region

# Get EC2 instance details
$instance = Get-EC2Instance -InstanceId $InstanceId
$ec2 = $instance.Reservations.Instances[0]

Write-Host "`n--- EC2 Instance Info ---"
Write-Host "Instance ID: $InstanceId"
Write-Host "Availability Zone: $($ec2.Placement.AvailabilityZone)"
Write-Host "Instance Type: $($ec2.InstanceType)"
Write-Host "State: $($ec2.State.Name)"
Write-Host ""

# 🔐 SECURITY GROUPS
Write-Host "--- Associated Security Groups ---"
foreach ($sg in $ec2.SecurityGroups) {
    Write-Host "Security Group ID: $($sg.GroupId) | Name: $($sg.GroupName)"
}
Write-Host ""

# 🔒 VOLUMES & KMS
Write-Host "--- Encrypted Volumes & KMS Keys ---"
$volumeIds = $ec2.BlockDeviceMappings | ForEach-Object { $_.Ebs.VolumeId }

foreach ($volId in $volumeIds) {
    $vol = Get-EC2Volume -VolumeId $volId
    $kmsKeyArn = $vol.KmsKeyId

    if ($kmsKeyArn) {
        $kmsKeyId = $kmsKeyArn.Split("/")[-1]

        # Get KMS Key metadata
        $kmsKey = Get-KMSKey -KeyId $kmsKeyId
        $keyMetadata = $kmsKey.KeyMetadata

        # Get aliases
        $aliases = Get-KMSAlias | Where-Object { $_.TargetKeyId -eq $kmsKeyId }

        Write-Host "Volume ID: $volId"
        Write-Host "KMS Key ID: $kmsKeyId"
        Write-Host "KMS Key ARN: $kmsKeyArn"
        Write-Host "Key State: $($keyMetadata.KeyState)"
        Write-Host "Creation Date: $($keyMetadata.CreationDate)"
        Write-Host "Key Aliases: $($aliases.AliasName -join ', ')"
        Write-Host "--------------------------------------------"
    }
    else {
        Write-Host "Volume ID: $volId is NOT encrypted."
    }
}
