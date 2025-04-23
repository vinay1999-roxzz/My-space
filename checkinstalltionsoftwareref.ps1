Reads a log file from C:\Temp\vm_installation_log.txt

---Example of text file
[INFO] Installing .Net2.0 installation...
[INFO]  .Net2.0 installation completed successfully.
[INFO] Installing Protocol...
[ERROR] protocol installation failed: Dependency not found.

# Path to the log file
$logFilePath = "C:\Temp\vm_installation_log.txt"

# Check if file exists
if (-Not (Test-Path $logFilePath)) {
    Write-Error "Log file not found at $logFilePath"
    exit
}

# Read log content
$logContent = Get-Content -Path $logFilePath

# Initialize variables
$currentPackage = $null
$results = @()

foreach ($line in $logContent) {
    if ($line -match "\[INFO\] Installing (.+)\.\.\.") {
        $currentPackage = $matches[1]
    } elseif ($line -match "\[INFO\] $currentPackage installation completed successfully.") {
        $results += [PSCustomObject]@{
            Package = $currentPackage
            Status  = "Success"
            Error   = ""
        }
        $currentPackage = $null
    } elseif ($line -match "\[ERROR\] $currentPackage installation failed: (.+)") {
        $results += [PSCustomObject]@{
            Package = $currentPackage
            Status  = "Failed"
            Error   = $matches[1]
        }
        $currentPackage = $null
    }
}

# Output the results
$results | Format-Table -AutoSize

Package   Status  Error                  
-------   ------  -----                  
Net2.0  Success                       
protocol  Failed  Dependency not found. 
