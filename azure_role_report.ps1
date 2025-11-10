# Retrieves all Azure AD directory roles and their members and exports to CSV.
# Placeholders have been added for paths.

Connect-AzureAD

$roles = Get-AzureADDirectoryRole
$roleAssignments = @()

foreach ($role in $roles) {
    $members = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
    foreach ($member in $members) {
        $roleAssignments += [PSCustomObject]@{
            RoleName            = $role.DisplayName
            MemberType          = $member.ObjectType
            MemberDisplayName   = $member.DisplayName
            MemberUserPrincipal = $member.UserPrincipalName
        }
    }
}

$date = Get-Date -Format "MM.dd.yyyy"
$reportPath = "<output_path>\AzureAD_Role_Assignments_$date.csv"
$roleAssignments | Export-Csv -Path $reportPath -NoTypeInformation
