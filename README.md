# M365 Identity and Role Reporting

PowerShell scripts to extract and analyze Azure Active Directory and Microsoft Purview role data, helping administrators understand role assignments, group memberships, and reporting hierarchies across tenants.

## Overview
These scripts were built to automate recurring reporting tasks in large M365 environments.  
They pull user, role, and group information, normalize the output, and export it to CSV for audit and governance review.

## Included Scripts

| Script | Description |
|--------|--------------|
| **azure_role_report.ps1** | Connects to Azure AD and exports all role assignments with member details. |
| **purview-role-report.ps1** | Extracts all Purview role groups and their members, mapping roles to users or service principals. |
| **populate-azuread-group.ps1** | Imports users from a CSV of SIDs and adds them to a specified Azure AD group, handling duplicates and validation. |
| **manager-org-report.ps1** | Recursively generates an organizational chart report for a given manager and all direct/indirect reports. |

All file paths and tenant IDs have been replaced with placeholders such as `<Path>` or `<ObjectId>`.

## Prerequisites
- PowerShell 7+  
- AzureAD or Microsoft Graph modules installed  
- Admin credentials or service principal with:
  - `Directory.Read.All`
  - `Group.Read.All`
  - `User.Read.All`

## Example Usage

```powershell
# Export Azure AD role assignments
.\get-azuread-role-assignments.ps1 -OutputPath "<Path>\RoleAssignments.csv"

# Generate full manager org hierarchy
.\export-manager-org-report.ps1 -ManagerUPN "manager@domain.com" -OutputPath "<Path>\OrgReport.csv"
