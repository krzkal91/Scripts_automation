# Created:    20.06.2019
# Updated:    27.08.2019
# version:    1.11


{Husk at filen maa hete NyBruker for at scriptet skal virke.}

#Get data

$EmployeeRecord= @{}
$data = Get-Content -Path "C:\Brukeroprettelse\NyBruker.csv"
foreach($line in $data) {
    $EmployeeRecord.Add($line.Split(';')[0],$line.Split(';')[1])
}

$secondname = $EmployeeRecord.Mellomnavn
$Surname = $EmployeeRecord.Etternavn
if(![string]::IsNullOrWhiteSpace($secondname)) {
    $givenName = $EmployeeRecord.Fornavn +" "+$secondname
    $UserName = $givenName.Substring(0,1) -replace "å","a" -replace "æ","a" -replace "ø","o"
    $UserName = $UserName + $secondname.Substring(0,1) -replace "å","a" -replace "æ","a" -replace "ø","o"
    $UserName = $UserName + $Surname -replace "å","a" -replace "æ","a" -replace "ø","o"
} else {
    $givenName = $EmployeeRecord.Fornavn
    $UserName = $givenName.Substring(0,1) -replace "å","a" -replace "æ","a" -replace "ø","o"
    $UserName = $UserName + $Surname -replace "å","a" -replace "æ","a" -replace "ø","o"
}
$AccountExpires = $EmployeeRecord.Sluttdato
$company = $EmployeeRecord.Firma
$department = $EmployeeRecord.Avdeling
$employeeNumber = $EmployeeRecord.Ansattnr
$PrimarySMTPAddress = $givenName -replace "å","a" -replace "æ","a" -replace "ø","o"
$PrimarySMTPAddress = $PrimarySMTPAddress + " " + $surname -replace "å","a" -replace "æ","a" -replace "ø","o"
$PrimarySMTPAddress = ($PrimarySMTPAddress + "@domainname.no") -replace ' ','.'
$mobile = $EmployeeRecord.Mobil
$sn = $EmployeeRecord.Etternavn -replace "å","a" -replace "æ","a" -replace "ø","o"
$title = $EmployeeRecord.Stilling
$upn = $givenName -replace "å","a" -replace "æ","a" -replace "ø","o"
$upn = $upn + " " + $surname -replace "å","a" -replace "æ","a" -replace "ø","o"
$upn = ($upn + "@entur.org") -replace ' ','.'
$tDisplayName = $surname + " " + $givenName
$cn = $UserName
$description = $EmployeeRecord.Lokasjon
$manageremail = $EmployeeRecord.Ledersepost


if (!($Server)) {

    $Server = 'DOMAIN_CONTROLLER_NAME'

}


#Create user

New-ADUser -Name $UserName -Surname $surname -DisplayName $tDisplayName -Department $Department -Title $Title -Company $company -SamAccountName $UserName -Manager $manager -Description $Description  -AccountPassword (ConvertTo-SecureString -AsPlainText "Velkommen2019" -Force) -ChangePasswordAtLogon 1 -OtherAttributes @{'cn'=$cn;'mobile'=$mobile;'GivenName'=$givenName;'mail'=$PrimarySMTPAddress;'EmployeeNumber'=$employeeNumber;} -Server $Server -Path "OU=Users,OU=EnTur,OU=Central,DC=entur,DC=local" -ErrorVariable UserCreateError


#Add to groups

Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "Alle-i-DOMAIN" -Server $Server
Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_APV_Firefox_NO" -Server $Server
Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_R____" -Server $Server
Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_U____" -Server $Server
Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_O____" -Server $Server

#Set attributes - based on expiration 2 possibilities
Set-ADUser -Identity $UserName -Description "COMPANYNAME $Description" -UserPrincipalName "$upn" -Replace @{mailnickname=$UserName}

if([string]::IsNullOrWhiteSpace($AccountExpires)) {
    Clear-ADAccountExpiration -Identity $UserName
} else {
    $AccountExpires = $AccountExpires -replace "\.","/"
    Set-ADUser -Identity $UserName -AccountExpirationDate $AccountExpires
}

#Confirm
$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup("Bruker ble oprettet",0,"Done",0x1)

#Pause, ask for automatic e-mail.

$confirmation = Read-Host "Skriv inn Y hvis du vil sende automatisk e-post"
if ($confirmation.ToLower() -eq 'y') {

    #Send-MailMessage
    $Encoding = 'utf8'
    $From = (Read-Host  "Skriv inn ditt VY e-post adresse, i pop-up vinduet skriv inn ditt e-post adresse og passord")
    $To = $manageremail
    $Cc = "HREMAIL@DOMAIN.no"
    $Subject = "Ny bruker for $givenName $surname ble oprettet"
    $Body =
    "Hei!

 Vi har registrert en ny bruker i AD.

 Brukernavn: $UserName
 E-post: $PrimarySMTPAddress
 Passord: THISISTHEPASS!!!19

 Vennligst send e-post til SUPPORTEMAIL eller ring TELEPHONENUMBER om det oppstår noe feil.

 Hilsen,
 IT Service Desk"


    $SMTPServer = "EXCHANGESERVER"
    $SMTPPort = "25"
    Send-MailMessage -Encoding $Encoding -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) –DeliveryNotificationOption OnSuccess
    #Confirm
    $wshell = New-Object -ComObject Wscript.Shell

    $wshell.Popup("E-post ble sendt",0,"Done",0x1)
}
