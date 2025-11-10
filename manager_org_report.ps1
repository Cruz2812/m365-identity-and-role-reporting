# Recursively exports a manager's org chart from Azure AD.

Connect-AzureAD

$managerUPN = Read-Host "Enter the User Principal Name (email) of the top-level manager"
$topManager = Get-AzureADUser -ObjectId $managerUPN
if (-not $topManager) {
    Write-Host "Manager not found." -ForegroundColor Red
    exit
}

$global:reportList = New-Object System.Collections.Generic.List[Object]

function Get-AllReportsRecursive {
    param(
        [string]$ManagerObjectId,
        [string]$ManagerDisplayName
    )
    $reports = Get-AzureADUserDirectReport -ObjectId $ManagerObjectId
    foreach ($report in $reports) {
        $reportObj = [PSCustomObject]@{
            ManagerName      = $ManagerDisplayName
            EmployeeName     = $report.DisplayName
            EmployeeUPN      = $report.UserPrincipalName
            EmployeeJobTitle = $report.JobTitle
        }
        $global:reportList.Add($reportObj)
        Get-AllReportsRecursive -ManagerObjectId $report.ObjectId -ManagerDisplayName $report.DisplayName
    }
}

Get-AllReportsRecursive -ManagerObjectId $topManager.ObjectId -ManagerDisplayName $topManager.DisplayName

if ($global:reportList.Count -eq 0) {
    Write-Host "No reports found under $($topManager.DisplayName)."
} else {
    $outPath = "<output_path>\ManagerOrgReport_$($topManager.DisplayName).csv"
    $global:reportList | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
    Write-Host "Report exported to $outPath" -ForegroundColor Green
}
