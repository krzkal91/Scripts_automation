
# Name: WipRix
# Created 03.12.2019
# Created: Krzysztof Kalinowski & Patryk Kolodziej
# Version 1.0
 
 
#REGISTERING FUNCTIONS, IMPORTS, ETC.
 
 
Add-PSSnapin Citrix.*
$version = "v 1.0"
 
#map X: drive
 
New-PSDrive -Name "X" -PSProvider "FileSystem" -Root "\\FILESHARE_IN_DOMAIN\profiles2008R2$" -Persist -ErrorAction SilentlyContinue
 
#Check if given user has active or disconnected sessions
 
function CheckUser {
    $global:Textbox2V = $TextBox2.text
    $sessions = Get-XASession -AccountDisplayName "DOMAINNNAME\$TextBox2V"
 
if($sessions) {
 
$message = "$Textbox2V is logged in"
 
[System.Windows.MessageBox]::Show($message)
 
 }
    else {
 
$message = "NO sessions found for user $Textbox2V"
 
[System.Windows.MessageBox]::Show($message)
   
 }
}
 
 # log off all sessions for user if user is active or disconnected
function LogOffSession {
 
$global:Textbox2V = $TextBox2.text
$sessions = Get-XASession -AccountDisplayName "DOMAINNNAME\$TextBox2V"
 
if($sessions) {
 
Get-XASession -AccountDisplayName "DOMAINNNAME\$TextBox2V" | Stop-XASession
 
$message = "$Textbox2V got logged off"
 
[System.Windows.MessageBox]::Show($message)
 
 }
else {
 
$message = "NO sessions found for user $Textbox2V No logoff"
 
[System.Windows.MessageBox]::Show($message)
   
 }
 
}
 
#rename the old Citrix profile
 
function NewProfile {
    $global:Textbox2V = $TextBox2.text
    $sessions = Get-XASession -AccountDisplayName "DOMAINNNAME\$TextBox2V"
    if(!$sessions) {
        $randomInt = Get-Random
        Rename-Item -Force X:\$TextBox2V.DOMAINNNAME.V2 -NewName X:\$TextBox2V.DOMAINNNAME.V2$randomInt
        $message = "$Textbox2V got a new Citrix profile created"
        [System.Windows.MessageBox]::Show($message)
    }
    else {
        $message = "User $Textbox2V is active, no new Citrix profile creation"
        [System.Windows.MessageBox]::Show($message)
    }
}
 
 
#ADD TO g_apl_smspasscode, CHECK IF MOBILE EXISTS
 
function SmsPasscode {
    $global:Textbox2V = $TextBox2.text
 
$mobile = Get-ADUser $Textbox2V -properties Telephonenumber | select Telephonenumber
 
if($mobile -match '\d') {
 
Add-ADGroupMember -Identity G_APL_SMSPasscode_Nettbuss -Members $Textbox2V
 
$message = "User $Textbox2V added to G_APL_SMSPasscode_DOMAINNNAME, mobile is registered"
    [System.Windows.MessageBox]::Show($message)
 
}
    else {
 
$message = "User $Textbox2V has no mobile registered, must contact HR"
    [System.Windows.MessageBox]::Show($message)
 
}
}
 
 
# CREATING FORM, MAIN THREAD
 
$Form = New-Object System.Windows.Forms.Form
$Form.ClientSize                 = '400,450'
$Form.text                       = "WipRix $version"
$Form.TopMost                    = $false
$Form.BackColor                  = "#292929"
$Form.ForeColor                   = "#ffffff"
$PictureBox1                     = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width               = 300
$PictureBox1.height              = 300
$PictureBox1.location            = New-Object System.Drawing.Point(45,-105)
$PictureBox1.imageLocation       = "C:\Projects\akka\WipRix\WipRix_logo.png"
$PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$Form.controls.AddRange(@($PictureBox1))
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "NY PROFIL"
$Button1.width                   = 141
$Button1.height                  = 40
$Button1.location                = New-Object System.Drawing.Point(130,275)
$Button1.Font                   = 'Microsoft Sans Serif,10'
$Button1.Add_Click(
        {
            NewProfile
        })
 
$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "LOGG AV"
$Button2.width                   = 142
$Button2.height                  = 42
$Button2.location                = New-Object System.Drawing.Point(130,326)
$Button2.Font                    = 'Microsoft Sans Serif,10'
$Button2.Add_Click({LogOffSession})
 
$Button4                         = New-Object system.Windows.Forms.Button
$Button4.text                    = "SMS PASSCODE"
$Button4.width                   = 142
$Button4.height                  = 42
$Button4.location                = New-Object System.Drawing.Point(130,220)
$Button4.Font                    = 'Microsoft Sans Serif,10'
$Button4.Add_Click({SmsPasscode})
 
$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 143
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(125,130)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'
$TextBox2.Add_GotFocus({
 
    if ($TextBox2.Text -eq 'Username') {
        $TextBox2.Text = ''
    }
})
 
$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "Sjekk bruker"
$Button3.width                   = 118
$Button3.height                  = 39
$Button3.location                = New-Object System.Drawing.Point(140,165)
$Button3.Font                    = 'Microsoft Sans Serif,10'
$Button3.Add_Click(
        {
            CheckUser
        }
 
)
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Coded by "
$Label1.BackColor                = "#292929"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(175,380)
$Label1.Font                     = 'Microsoft Sans Serif,8'
$Label1.ForeColor                = "#ffffff"
 
$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Krzysztof Kalinowski & Patryk Kolodziej"
$Label2.BackColor                = "#292929"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(82,407)
$Label2.Font                     = 'Microsoft Sans Serif,10'
$Label2.ForeColor                = "#ffffff"
 
$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "$version"
$Label4.BackColor                = "#292929"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(361,409)
$Label4.Font                     = 'Microsoft Sans Serif,8'
$Label4.ForeColor                = "#ffffff"
$Form.Controls.Add($Label3)
$Form.Controls.Add($Label2)
$Form.Controls.Add($Label1)
$Form.Controls.Add($Label4)
$Form.Controls.Add($Button1)
$Form.Controls.Add($Button2)
$Form.Controls.Add($Button4)
$Form.Controls.Add($TextBox2)
$Form.Controls.Add($Button3)
$Form.Controls.Add($PictureBox1)
 
$Form.ShowDialog()
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
 
 
