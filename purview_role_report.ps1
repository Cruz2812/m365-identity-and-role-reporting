# Export Purview role groups, members, and roles.

Connect-IPPSSession -UseRPSSession:$false
Connect-AzureAD

$roleGroups = Get-RoleGroup
$date = Get-Date -Format "MM.dd.yyyy"
$results = @()

foreach ($roleGroup in $roleGroups) {
    $members = $roleGroup.Members
    $roleNames = $roleGroup.RoleAssignments
    foreach ($member in $members) {
        $memberGuid = $member.Substring(($member.IndexOf("onmicrosoft.com/") + 16), 36)
        $memberName = $null
        $userPrincipalName = $null
        $accountStatus = $null
        try {
            $memberInfo = Get-AzureADUser -ObjectId $memberGuid
            $memberName = $memberInfo.DisplayName
            $userPrincipalName = $memberInfo.UserPrincipalName
            $accountStatus = $memberInfo.AccountEnabled
        } catch {
            try {
                $memberInfo = Get-AzureADGroup -ObjectId $memberGuid
                $memberName = $memberInfo.DisplayName
                $userPrincipalName = $memberInfo.Mail
                $accountStatus = "True"
            } catch {
                $memberName = $memberGuid
                $userPrincipalName = "Unknown"
                $accountStatus = "False"
            }
        }

        foreach ($roleName in $roleNames) {
            $cleanRoleName = $roleName
            $results += [PSCustomObject]@{
                RoleGroup        = $roleGroup.DisplayName
                MemberName       = $memberName
                UserPrincipalName= $userPrincipalName
                AccountStatus    = $accountStatus
                Roles            = $cleanRoleName
            }
        }
    }
}

$results | Export-Csv -Path "<output_path>\Purview_Role_Report_$date.csv" -NoTypeInformation
