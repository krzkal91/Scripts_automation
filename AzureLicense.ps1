# Created by: Krzysztof Kalinowski
# Created:    20.02.2020
# Updated:    ---
# version:    1.00 AzureConnect
 
#Imports, declarations
Get-Module MSOnline
 
$users = New-Object System.Collections.Generic.List[string]
$fullUsers = New-Object System.Collections.Generic.List[Object]
$syncedUsers = New-Object System.Collections.Generic.List[Object]
$pendingUsers = New-Object System.Collections.Generic.List[Object]
 
#Retrieve info from on-prem
function Get-OnpremData {
    foreach($elem in $users) {
        try{
        $tmp = Get-ADUser $elem -Properties samaccountname, EmailAddress, Title -ErrorAction Stop
        $fullUsers.Add($tmp)
        } catch {
        Write-Host "$elem not found in on-prem AD"
        }
    }
 
}
 
 
#Find AzureAD user
function Find-AzureUser {
 
    if(!($intuneCred)) {
        $intuneCred = Get-Credential
    }
 
    Connect-MsolService -Credential $intuneCred
 
    $syncedUsers.Clear()
    $pendingUsers.Clear()
    foreach($us in $fullUsers) {
            try {
                $user = Get-MsolUser -UserPrincipalName $us.EmailAddress -ErrorAction Stop
                Write-Host "User $($us.EmailAddress) found in Azure. Proceeding with license/group assigning"
                $syncedUsers.Add($us)
            } catch {
                Write-Host "No $($us.EmailAddress) user found in Azure yet. Will not assign"
                $pendingUsers.Add($us)
               }
    }
}
 
#Azure-Connect declaration
function Azure-Connect {
   
    foreach($u in $syncedUsers) {
   
    if($u.Title.ToLower() -contains "innleid") {
        Set-MsolUser -UserPrincipalName $u.EmailAddress -UsageLocation NO
        Set-MsolUserLicense -UserPrincipalName $u.EmailAddress -AddLicenses "ACCOUNTNAME:ENTERPRISEPACK"
    } else {
        Set-MsolUser -UserPrincipalName $u.EmailAddress -UsageLocation NO
        Add-MsolGroupMember -GroupObjectId 10e824a38895-4689-cc2a-9378-ab453a42  -GroupMemberType User -GroupMemberObjectId $user.ObjectId
    }
 
    }
}


#Input from user
function Get-Input {
    try {
    $users.Clear()
        Write-Host "Type in samaccountname/short username for newly created Entur users separated with whitespace."
        Write-Host "Example: mdahlen sbbakken"
        $inp = Read-Host "Usernames:" -ErrorAction Stop
        $splitted = $inp.Split(" ")
        foreach($u in $splitted) {
            $u = $u.Trim()
            $u = $u.ToLower()
            $users.Add($u)
    }}
    catch {
    Write-Host "Error occurred. Try again"
    Get-Input
    }
}
 
#Execution LOOP
function Run-Script {
Find-AzureUser
Azure-Connect
 
if($pendingUsers.Count -gt 0) {
Write-Host "Still some pending users, $($pendingUsers.Count) of $($fullUsers.Count) remaining. Will retrigger in 20 mins"
Start-Sleep -Seconds 1200
$fullUsers = $pendingUsers
Run-Script
} else {
Write-Host "All users synced and assigned license/access to group. This session will terminate within 10 secs"
Start-Sleep -Seconds 10
}
}
 
#Main thread
$intuneCred = $null
Get-Input
Run-Script
 
