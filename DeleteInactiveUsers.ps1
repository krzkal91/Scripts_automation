#Name: DeleteInactiveUsers
#Version: 1.1
#Created: 10.12.2019
#Updated: 14.01.2020
#Created by: Krzysztof Kalinowski
#Updated by: Krzysztof Kalinowski

$today = Get-Date
$smtpServer="MAILSERVER"
$adminEmailAddr="ADMINEMAIL"
$from = "SERVICEEMAIL"

#Find all deactivated users within OU Central/Inactive Users
Write-Output "" ; "" ; ""
Write-Output "Script is starting"
Write-Output "" ; "" ; ""
Write-Output "Searching in OU Central/Inactive Users for deactivated users"
Write-Output "" ; "" ; ""
$inactiveUsersAll = Get-ADUser -filter {Enabled -eq $False} -Properties * | Where-Object {($_.CanonicalName.startsWith("OUPATHNAME") )} | Select-Object DisplayName, whenChanged, samaccountname
Write-Output "" ; "" ; ""
Write-Output "Found following matches"
Write-Output "" ; "" ; ""
$inactiveUsersAll
Write-Output "" ; "" ; ""

#loop through all of them
Write-Output "Checking the last modification timestamp"
Write-Output "" ; "" ; ""
$rand = Get-Random

#Creating log file
New-Item  -Path "LOCALPATHONCDRIVE_$rand.txt" -ItemType File

foreach($inactiveUser in $inactiveUsersAll) {
    $namn = $inactiveUser.samaccountname
    $whenUserChanged = $inactiveUser.Whenchanged
    [int]$result = [convert]::ToInt32((New-TimeSpan -Start $whenUserChanged -End $today).Days)

    #If user has been changed/moved for more than 30 days ago, display message and delete
    if($result -gt 30) {

        try{
            Remove-ADUser $namn -Confirm:$false
            Write-Output "$namn no changes for $result days. Performing delete"
            Add-Content -Path "LOCALPATHONCDRIVE_$rand.txt" -Value "$namn no changes for $result days. Performing delete"
        }
        catch {
            Write-Output "$namn no changes for $result days. Tried to delete but an error has occured"
            Add-Content -Path "LOCALPATHONCDRIVE_$rand.txt" -Value "$namn no changes for $result days. Tried to delete but an error has occured"
        }

    } elseif($result -le 30) {
        Write-Output "$namn modified $result days ago. No actions taken"
        Add-Content -Path "LOCALPATHONCDRIVE_$rand.txt" -Value "$namn modified $result days ago. No actions taken"
    }
}

Write-Output "" ; "" ; ""
Write-Output "Sending e-mail log"
Write-Output "" ; "" ; ""

$body="
    Delete Inactive Users Log Attached for $today
"
try {
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $adminEmailAddr -subject "Delete Inactive Users Log Entur" -body $body -bodyasHTML -Attachments "LOCALPATHONCDRIVE_$rand.txt" -priority High -Encoding "UTF8" -ErrorAction Stop -ErrorVariable err
} catch {
    write-host "Error: Failed to email log to $adminEmailAddr via $smtpServer"
}

Write-Output "" ; "" ; ""
Write-Output "Script is done running"
