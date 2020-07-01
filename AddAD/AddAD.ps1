<# 
.SYNOPSIS
Created:    03.04.2020
Created by: Krzysztof Kalinowski (krzysztof.kalinowski@icloud.com)
Last updated:  04.06.2020
Version: 2.2
 

.DESCRIPTION

GUI version for Entur user creation and basic management with some additional features  
Upgraded version utilizing parts of script created by Krzysztof Kalinowski and Patryk Kolodziej 
Functionalities:
    - Authenticates users through AzureAD
    - creates Users in AD with given input
    - User creation possible both manually by typing the necessary values or semi-automated by providing the xlsx file that is valid with the schema.
	Two xlsx parsing modes: for single user creation and for batch creation (one sheet per user within the input file).
    - sends email to HR and manager post creation - if user chooses to
    - after successful sync - we can check status of Azure AD and get all Licenses and Azure Groups user is member of
    - Can add MFA Azure access for the user if existent in AzureAD and an access group responsible for E3 license
    - Exception handling OFC...
    - All served in a User-friendly GUI

 #>

#IMPORTS SETUPS
Import-Module AzureAD
Get-Module AzureAD

#Script finding a username compliant with a policy without any risk of overwriting
. C:\Brukeroprettelse\AddAD\Get-ValidUsername.ps1

#Form Builder
. C:\Brukeroprettelse\AddAD\GUI\MainForm.ps1
. C:\Brukeroprettelse\AddAD\GUI\AzureCheckupForm.ps1
. C:\Brukeroprettelse\AddAD\GUI\OnpremADForm.ps1
. C:\Brukeroprettelse\AddAD\GUI\SendEmailForm.ps1
. C:\Brukeroprettelse\AddAD\GUI\Build-Grid.ps1
. C:\Brukeroprettelse\AddAD\GUI\ExcelModeForm.ps1

#VALIDATION and establishing a connection
try{
. C:\Brukeroprettelse\AddAD\Val\Validate.ps1
}catch { exit
$Form.Close()
}


### Business Logic ###



# Create user function
function Create-User {

   $givenname = ($InputFornavn.Text).Trim()
   $Surname = ($InputEtternavn.Text).Trim()
   $AccountExpires = $InputSluttdato.Text
   $company = $InputFirma.Text
   $department = $InputAvdeling.Text
   $PrimarySMTPAddress = $givenName -replace "å","a" -replace "æ","a" -replace "ø","o"
   $PrimarySMTPAddress += ".$surname" -replace "å","a" -replace "æ","a" -replace "ø","o" -replace " ","."
   $PrimarySMTPAddress += "@domain.com"
   $mobile = $InputMobil.Text
   $sn = $InputEtternavn.Text -replace "å","a" -replace "æ","a" -replace "ø","o"
   $title = $InputStilling.Text
   $upn = $PrimarySMTPAddress
   $tDisplayName = $surname + " " + $givenName
   $cn = $UserName
   $description = $InputLokasjon.Text
   $manageremail = ($InputLeder.Text).Trim()


if (!($Server)) {

   $Server = 'DOMAIN-CONTROLLER.domain.com'

}

    #Create user
    try {
        $UserName = Get-ValidUsername -firstname $givenname -secondname $Surname
        New-ADUser -Name $UserName -Surname $surname -DisplayName $tDisplayName -Department $Department -Title $Title -Company $company -SamAccountName $UserName -Manager $manager -Description $Description  -AccountPassword (ConvertTo-SecureString -AsPlainText "Velkommen2019" -Force) -ChangePasswordAtLogon 1 -OtherAttributes @{'cn'=$UserName;'mobile'=$mobile;'GivenName'=$givenname;'mail'=$PrimarySMTPAddress;} -Server $Server -Path "OU=Users,OU=Company,OU=Central,DC=comp,DC=local" -ErrorVariable UserCreateError -ErrorAction Stop
   

        #Add to groups 

        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "Alle-i-Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_APV_Firefox_NO" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_R_Company_" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_U_Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_O_Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_Role_TempAdmin" -Server 'DOMAIN-CONTROLLER.domain.com'


        #Set attributes - based on expiration 2 possibilities
        Set-ADUser -Identity $UserName -Description "Entur AS $Description" -UserPrincipalName "$upn" -Replace @{mailnickname=$UserName}  -ErrorAction Stop

        if([string]::IsNullOrWhiteSpace($AccountExpires)) {
                Clear-ADAccountExpiration -Identity $UserName
            } else {
                $AccountExpires = $AccountExpires -replace "\.","/"
                Set-ADUser -Identity $UserName -AccountExpirationDate $AccountExpires
            }

        #Confirm
        $wshell = New-Object -ComObject Wscript.Shell 

        $wshell.Popup("Bruker $UserName ble oprettet, primary e-mail $upn",0,"Done", 0x4 + 4096)

        $SendEmailQuestionForm.ShowDialog()
        [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null



} catch {

    $wshell = New-Object -ComObject Wscript.Shell

    $wshell.Popup("Bruker $UserName ble ikke helt oprettet, en feil har oppstått. `n $_",0,"Error", 0x4 + 4096)


}


}




#GetBatchFromExcel

function Get-BatchFromExcel{
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
            InitialDirectory = [Environment]::GetFolderPath('Desktop') 
            Filter = 'Documents SpreadSheet (*.xlsx)|*.xlsx'
        }
        [void]$FileBrowser.ShowDialog()
        $file = $FileBrowser.FileName


        $Excel = New-Object -ComObject Excel.Application
        $Workbook = $Excel.workbooks.open($file)
        $Worksheets = $Workbook.sheets | Select-Object -Property Name   

        Foreach($Sheet in $WorkBook.Sheets) {  

                $fornavn = $Sheet.Cells.Item(1, 2).Text  
                $etternavn = $Sheet.Cells.Item(2, 2).Text  
                $expiry =  $Sheet.Cells.Item(4, 2).Text
                $mobil =  $Sheet.Cells.Item(5, 2).Text
                $arbeidssted = $Sheet.Cells.Item(7, 2).Text
                $stilling = $Sheet.Cells.Item(8, 2).Text
                $avdeling = $Sheet.Cells.Item(9, 2).Text
                $firma = $Sheet.Cells.Item(10, 2).Text
                $leder = $Sheet.Cells.Item(12, 2).Text
                Write-Host 'Creating' $fornavn $etternavn $expiry $mobil $arbeidssted $stilling $avdeling $firma $leder
                Create-UserExcel $fornavn $etternavn $expiry $mobil $arbeidssted $stilling $avdeling $firma $leder
            }
}


#GetOneFromExcel

function Get-OneFromExcel{
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
            InitialDirectory = [Environment]::GetFolderPath('Desktop') 
            Filter = 'Documents SpreadSheet (*.xlsx)|*.xlsx'
        }
        [void]$FileBrowser.ShowDialog()
        $file = $FileBrowser.FileName


        $Excel = New-Object -ComObject Excel.Application
        $Workbook = $Excel.workbooks.open($file)
        $Worksheets = $Workbook.sheets | Select-Object -Property Name 
        
         

        $Sheet = $WorkBook.sheets[1]
        $fornavn = $Sheet.Cells.Item(1, 2).Text  
        $etternavn = $Sheet.Cells.Item(2, 2).Text 
        $expiry =  $Sheet.Cells.Item(4, 2).Text
        $mobil =  $Sheet.Cells.Item(5, 2).Text
        $arbeidssted = $Sheet.Cells.Item(7, 2).Text
        $stilling = $Sheet.Cells.Item(8, 2).Text
        $avdeling = $Sheet.Cells.Item(9, 2).Text
        $firma = $Sheet.Cells.Item(10, 2).Text
        $leder = $Sheet.Cells.Item(12, 2).Text
        Write-Host 'Creating' $fornavn $etternavn $expiry $mobil $arbeidssted $stilling $avdeling $firma $leder
        $Excel.workbooks.close()
        Create-UserExcel $fornavn $etternavn $expiry $mobil $arbeidssted $stilling $avdeling $firma $leder

}


#Create user from Excel
function Create-UserExcel {
    Param(
    [String] $fornavn,
    [String] $etternavn, 
    [String] $expiry,
    [String] $mobil,
    [String] $arbeidssted,
    [String] $stilling,
    [String] $avdeling,
    [String] $firma,
    [String] $leder
  )

if ($ExcelModeForm) {
    $ExcelModeForm.Close()
}

   $givenname = $fornavn.Trim()
   $Surname = $etternavn.Trim()
   $AccountExpires = $expiry.Trim()
   $company = $firma.Trim()
   $department = $avdeling.Trim()
   $PrimarySMTPAddress = $givenName -replace "å","a" -replace "æ","a" -replace "ø","o" -replace " ","."
   $PrimarySMTPAddress += ".$Surname" -replace "å","a" -replace "æ","a" -replace "ø","o" -replace " ","."
   $PrimarySMTPAddress += "@domain.com"
   $mobile = $mobil.Trim()
   if([string]::IsNullOrWhiteSpace($mobile)) {
        $mobile = "99999999"
   }
   $sn = $Surname -replace "å","a" -replace "æ","a" -replace "ø","o"
   $title = $stilling.Trim()
   $upn = $PrimarySMTPAddress
   $tDisplayName = $Surname + " " + $givenName
   $cn = $UserName
   $description = $arbeidssted.Trim()
   $manageremail = $leder.Trim()

if (!($Server)) {

   $Server = 'DOMAIN-CONTROLLER.domain.com'

}

    #Create user
    try {
        $UserName = Get-ValidUsername -firstname $givenname -secondname $Surname
        New-ADUser -Name $UserName -Surname $surname -DisplayName $tDisplayName -Department $Department -Title $Title -Company $company -SamAccountName $UserName -Manager $manager -Description $Description  -AccountPassword (ConvertTo-SecureString -AsPlainText "Velkommen2019" -Force) -ChangePasswordAtLogon 1 -OtherAttributes @{'cn'=$UserName;'mobile'=$mobile;'GivenName'=$givenname;'mail'=$PrimarySMTPAddress;} -Server $Server -Path "OU=Users,OU=Company,OU=Central,DC=comp,DC=local" -ErrorVariable UserCreateError -ErrorAction Stop
   


        #Add to groups 

        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "Alle-i-Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_APV_Firefox_NO" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_R_Company_" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_U_Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_MAP_O_Company" -Server 'DOMAIN-CONTROLLER.domain.com'
        Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf "G_Role_TempAdmin" -Server 'DOMAIN-CONTROLLER.domain.com'


        #Set attributes - based on expiration 2 possibilities
        Set-ADUser -Identity $UserName -Description "Entur AS $Description" -UserPrincipalName "$upn" -Replace @{mailnickname=$UserName}  -ErrorAction Stop

        if([string]::IsNullOrWhiteSpace($AccountExpires)) {
                Clear-ADAccountExpiration -Identity $UserName
            } else {
                $AccountExpires = $AccountExpires -replace "\.","/"
                Set-ADUser -Identity $UserName -AccountExpirationDate $AccountExpires
            }

        #Confirm
        $wshell = New-Object -ComObject Wscript.Shell

        $wshell.Popup("Bruker $UserName ble oprettet, primary e-mail $upn",0,"Done", 0x4 + 4096)

        $SendEmailQuestionForm.ShowDialog()
        [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null



} catch {

    $wshell = New-Object -ComObject Wscript.Shell

    $wshell.Popup("Bruker $UserName ble ikke helt oprettet, en feil har oppstått. `n $_",0,"Error", 0x4 + 4096)


}


}

#Send-MailMessage function
function Send-Mail {
$time = (Get-Date).AddHours(1).ToString()
$Encoding = 'utf8'
$From = "addAD@domain.com"
$To ="$manageremail"
$Cc = "admin.numberone@domain.com", "admin.number2@domain.com", "hr.department@domain.com"
$Subject = "Ny bruker $Username for $givenName $surname ble oprettet"
$Body = 
"Hei!

 Vi har registrert en ny bruker i AD.

 Brukernavn: $UserName 
 E-post: $PrimarySMTPAddress
 Passord: Velkommen2019

 Vennligst send e-post til your.support@domain.com eller ring 0700 880 774 om det oppstår noe feil. 

 Alle tilganger skal være på plass om ca. 1 time fra dette tidspunktet, dvs. rundt $time

 Hilsen,
 IT Service Desk"
 


$SMTPServer = "outlook.online.server.domain.com"
$SMTPPort = "25"
$attachments = Get-ChildItem -Path C:\Brukeroprettelse\AddAD\Attachments |
ForEach-Object {$_.FullName}
Send-MailMessage -Encoding $Encoding -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachments $attachments -Credential $vyCreds –DeliveryNotificationOption OnSuccess
#Confirm
$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup("E-post ble sendt",0,"Done", 0x1 + 4096)


}


# Azure Sync form

function Azure-SyncForm {

if([string]::IsNullOrWhiteSpace($PrimarySMTPAddress)) {
    $AzureForm.ShowDialog()
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
} elseif(![string]::IsNullOrWhiteSpace($PrimarySMTPAddress)) {
    $InputMainEmailAzure.Text = $PrimarySMTPAddress
    $AzureForm.ShowDialog()
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}


}


#Excel mode function
function ExcelMode {
$ExcelModeForm.ShowDialog()
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}

# O365 Sync Lookup 
function O365-SyncLookup {
    
            try {
                $user = Get-AzureADUser -ObjectId $InputMainEmailAzure.Text -ErrorAction Stop
                $azureLicences = Get-AzureADUserLicenseDetail -ObjectId $user.ObjectId | select -ExpandProperty ServicePlans
                $arrList = New-Object System.Collections.ArrayList
                $arrList.AddRange($azureLicences)
                Build-Grid -datasource $arrList
            } catch {
                $azureMessageStatus = "No $($InputMainEmailAzure.Text) user found in Azure yet or cannot retrieve properties  `n $_"
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup($azureMessageStatus,0,"Error", 0x1 + 4096)
               }




}

# Azure Sync Lookup 
function Azure-SyncLookup {
    
            try {
                $user = Get-AzureADUser -ObjectId $InputMainEmailAzure.Text -ErrorAction Stop
                $azureGroups = Get-AzureADUserMembership -All $true  -ObjectId $user.ObjectId | select DisplayName, Description
                $arrList = New-Object System.Collections.ArrayList
                $arrList.AddRange($azureGroups)
                Build-Grid -datasource $arrList

            } catch {
                $azureMessageStatus = "No $($InputMainEmailAzure.Text) user found in Azure yet or cannot retrieve properties   `n $_"
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup($azureMessageStatus,0,"Error", 0x1 + 4096)
               }


            

}


# Azure MFA group Intune

function Add-MFA {
    try{
        $user = Get-AzureADUser -ObjectId $InputMainEmailAzure.Text -ErrorAction Stop
        Add-AzureADGroupMember -ObjectId 3d650a1b-a81f-7765s-ab9c-b829f6467hg6 -RefObjectId $user.ObjectId
        $azureMessageStatus = "User $($InputMainEmailAzure.Text)  found in Azure and _Intune_MFA added successfully"             
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($azureMessageStatus,0,"Done", 0x1 + 4096)
    } catch {
        $azureMessageStatus = "No $($InputMainEmailAzure.Text) user found in Azure yet or cannot change properties  `n $_"             
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($azureMessageStatus,0,"Error", 0x1 + 4096)

    }
}


# Azure E3 license group

function Add-E3 {
    try{
        $user = Get-AzureADUser -ObjectId $InputMainEmailAzure.Text -ErrorAction Stop
        Add-AzureADGroupMember -ObjectId ab453a42-cc2a-7623-9876-10e824a38895 -RefObjectId $user.ObjectId
        $azureMessageStatus = "User $($InputMainEmailAzure.Text)  found in Azure and _Intune_MAM og MDM brukere added successfully"             
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($azureMessageStatus,0,"Done", 0x1 + 4096)
    } catch {
        $azureMessageStatus = "No $($InputMainEmailAzure.Text) user found in Azure yet or cannot change properties  `n $_"             
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($azureMessageStatus,0,"Error", 0x1 + 4096)

    }
}





### SHOW MAIN FORM

$CheckSyncAzureButton.Add_Click({ ${$AzureForm.ShowDialog()
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    }
 })
$ADUserManagementButton.Add_Click({ ${$OnpremADForm.ShowDialog()
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
 }
 })
$ExitButton.Add_Click({ ${$Form.Close() }
 })


$Form.ShowDialog()
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null


