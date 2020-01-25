#Name: DeleteInactiveUsers
#Created: 10.12.2019
#Version: 1.0
#Created by: Krzysztof Kalinowski
 
$today = Get-Date
 
#Find all deactivated users within OU Central/Inactive Users
Write-Output "" ; "" ; ""
Write-Output "Script is starting"
Write-Output "" ; "" ; ""
Write-Output "Searching in OU Central/Inactive Users for deactivated users"
Write-Output "" ; "" ; ""
$inactiveUsersAll = Get-ADUser -filter {Enabled -eq $False} -Properties * | Where-Object {($_.CanonicalName.startsWith("DOMAINNAME/Central/Inactive Users/") )} | Select-Object DisplayName, whenChanged, samaccountname
Write-Output "" ; "" ; ""
Write-Output "Found following matches"
Write-Output "" ; "" ; ""
$inactiveUsersAll
Write-Output "" ; "" ; ""
 
#loop through all of them
Write-Output "Checking the last modification timestamp"
Write-Output "" ; "" ; ""
 
foreach($inactiveUser in $inactiveUsersAll) {
 
     $whenUserChanged = $inactiveUser.Whenchanged
     $result = (New-TimeSpan -Start $whenUserChanged -End $today).Days
 
     #If user has been changed/moved for more than 90 days ago, display message and delete
     if($result -gt 90) {
     $namn = $inactiveUser.samaccountname
     Write-Output "$namn no changes for over 90 days. Performing delete"
 
     #REMOVE THE COMMENT TO DELETE!!!
     #Remove-ADUser $namn
     }
}
Write-Output "" ; "" ; ""
Write-Output "Script is done running"
