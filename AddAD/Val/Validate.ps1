try {
    $vyCreds = Get-Credential -Message "Please provide your XXX credentials" 
    Connect-AzureAD -Credential $vyCreds -ErrorAction Stop
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Validation successful. Welcome $($vyCreds.UserName) `n $_",0,"Success",0x1)
    Disconnect-AzureAD

} catch {
     $wshell = New-Object -ComObject Wscript.Shell

    $wshell.Popup("Something went wrong. Report this message to you system administrator. `n`n`n $_",0,"Error",0x1)
    $Form.Close()
    exit

}
$password = ConvertTo-SecureString 'DUMMYpassword12345' -AsPlainText -Force
$intuneCred = New-Object System.Management.Automation.PSCredential ('dummy.account@domain.com', $password)
Connect-AzureAD -Credential  $intuneCred