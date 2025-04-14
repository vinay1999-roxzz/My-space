function Check-GitAndVSCode {
    $git = Get-Command git -ErrorAction SilentlyContinue
    $vscode = Get-Command code -ErrorAction SilentlyContinue

    if ($git -and $vscode) {
        return "OK"
    } else {
        return "KO"
    }
}

function Check-PowerShell7 {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue

    if ($pwsh) {
        return "OK"
    } else {
        return "KO"
    }
}

function Check-SQLServerPowerShell {
    $sqlModule = Get-Module -ListAvailable -Name SqlServer

    if ($sqlModule) {
        return "OK"
    } else {
        return "KO"
    }
}

# Run checks and set pipeline variables
$gitVsCodeResult = Check-GitAndVSCode
Write-Output "##vso[task.setvariable variable=GitAndVSCode]$gitVsCodeResult"

$pwshResult = Check-PowerShell7
Write-Output "##vso[task.setvariable variable=PowerShell7]$pwshResult"

$sqlResult = Check-SQLServerPowerShell
Write-Output "##vso[task.setvariable variable=SQLServerPowerShell]$sqlResult"
