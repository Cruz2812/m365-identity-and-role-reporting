# Reads a CSV of UserIDs, finds corresponding Azure AD users, handles duplicates, and adds them to a target group.

Connect-AzureAD

$date = Get-Date -Format "MM.dd.yyyy"
$csvFileInitialPath = "<input_csv_path>"
$imports = Import-Csv $csvFileInitialPath

$imports | ForEach-Object {
    if (-not $_.PSObject.Properties.Match("Email")) { $_ | Add-Member -MemberType NoteProperty -Name "Email" -Value "" }
    if (-not $_.PSObject.Properties.Match("isDuplicate")) { $_ | Add-Member -MemberType NoteProperty -Name "isDuplicate" -Value "" }
}

$duplicateUserIDs = @()
foreach ($import in $imports) {
    $UserID = $import.UserID
    $users = Get-AzureADUser -Filter "startswith(userPrincipalName, '$UserID')" | Where-Object { $_.UserPrincipalName -like "*.com" }
    if ($users.Count -gt 1) {
        $index = 1
        foreach ($user in $users) {
            if ($index -eq 1) {
                $import.Email = $user.UserPrincipalName
                $import.isDuplicate = "no"
            } else {
                $duplicateUserIDs += [PSCustomObject]@{
                    UserID         = $UserID
                    Email       = $user.UserPrincipalName
                    isDuplicate = "yes"
                }
            }
            $index++
        }
    } elseif ($users.Count -eq 1) {
        $import.Email = $users.UserPrincipalName
        $import.isDuplicate = "no"
    }
}

$export = $imports + $duplicateUserIDs
$finalCsv = "<output_path>\FinalUsers_$date.csv"
$export | Export-Csv -Path $finalCsv -NoTypeInformation

# Add users to group
$group = Get-AzureADGroup -ObjectId "<group_object_id>"
$results = @()
$users = Import-Csv $finalCsv

foreach ($user in $users) {
    $userObj = Get-AzureADUser -ObjectId $user.Email
    if ($userObj) {
        try {
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $userObj.ObjectId
            $results += [PSCustomObject]@{ Email = $user.Email; Status = "Success"; ErrorMessage = "" }
        }
        catch {
            $results += [PSCustomObject]@{ Email = $user.Email; Status = "Failure"; ErrorMessage = $_.Exception.Message }
        }
    } else {
        $results += [PSCustomObject]@{ Email = $user.Email; Status = "Failure"; ErrorMessage = "User not found" }
    }
}

$results | Export-Csv -Path "<output_path>\AddToGroup_Results_$date.csv" -NoTypeInformation
