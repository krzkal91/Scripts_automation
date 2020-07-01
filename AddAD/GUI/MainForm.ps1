##### MAIN FORM #####
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '649,427'
$Form.text                       = "Form"
$Form.BackColor                  = "#f2d8ae"
$Form.TopMost                    = $true

$InputFornavn                    = New-Object system.Windows.Forms.TextBox
$InputFornavn.multiline          = $false
$InputFornavn.width              = 200
$InputFornavn.height             = 20
$InputFornavn.location           = New-Object System.Drawing.Point(160,75)
$InputFornavn.Font               = 'Microsoft Sans Serif,10'

$Fornavn                         = New-Object system.Windows.Forms.Label
$Fornavn.text                    = "Fornavn"
$Fornavn.AutoSize                = $true
$Fornavn.width                   = 25
$Fornavn.height                  = 10
$Fornavn.location                = New-Object System.Drawing.Point(75,77)
$Fornavn.Font                    = 'Microsoft Sans Serif,10'

$Etternavn                       = New-Object system.Windows.Forms.Label
$Etternavn.text                  = "Etternavn"
$Etternavn.AutoSize              = $true
$Etternavn.width                 = 25
$Etternavn.height                = 10
$Etternavn.location              = New-Object System.Drawing.Point(61,148)
$Etternavn.Font                  = 'Microsoft Sans Serif,10'

$Stilling                        = New-Object system.Windows.Forms.Label
$Stilling.text                   = "Stilling"
$Stilling.AutoSize               = $true
$Stilling.width                  = 25
$Stilling.height                 = 10
$Stilling.location               = New-Object System.Drawing.Point(79,309)
$Stilling.Font                   = 'Microsoft Sans Serif,10'

$Firma                           = New-Object system.Windows.Forms.Label
$Firma.text                      = "Firma"
$Firma.AutoSize                  = $true
$Firma.width                     = 25
$Firma.height                    = 10
$Firma.location                  = New-Object System.Drawing.Point(84,247)
$Firma.Font                      = 'Microsoft Sans Serif,10'

$Mobil                           = New-Object system.Windows.Forms.Label
$Mobil.text                      = "Mobil"
$Mobil.AutoSize                  = $true
$Mobil.width                     = 25
$Mobil.height                    = 10
$Mobil.location                  = New-Object System.Drawing.Point(85,183)
$Mobil.Font                      = 'Microsoft Sans Serif,10'

$Sluttdato                       = New-Object system.Windows.Forms.Label
$Sluttdato.text                  = "Sluttdato"
$Sluttdato.AutoSize              = $true
$Sluttdato.width                 = 25
$Sluttdato.height                = 10
$Sluttdato.location              = New-Object System.Drawing.Point(67,216)
$Sluttdato.Font                  = 'Microsoft Sans Serif,10'

$Avdeling                        = New-Object system.Windows.Forms.Label
$Avdeling.text                   = "Avdeling"
$Avdeling.AutoSize               = $true
$Avdeling.width                  = 25
$Avdeling.height                 = 10
$Avdeling.location               = New-Object System.Drawing.Point(68,276)
$Avdeling.Font                   = 'Microsoft Sans Serif,10'

$Lokasjon                        = New-Object system.Windows.Forms.Label
$Lokasjon.text                   = "Lokasjon"
$Lokasjon.AutoSize               = $true
$Lokasjon.width                  = 25
$Lokasjon.height                 = 10
$Lokasjon.location               = New-Object System.Drawing.Point(68,346)
$Lokasjon.Font                   = 'Microsoft Sans Serif,10'

$LederEpost                      = New-Object system.Windows.Forms.Label
$LederEpost.text                 = "Leder e-post"
$LederEpost.AutoSize             = $true
$LederEpost.width                = 25
$LederEpost.height               = 10
$LederEpost.location             = New-Object System.Drawing.Point(43,383)
$LederEpost.Font                 = 'Microsoft Sans Serif,10'

$InputSluttdato                  = New-Object system.Windows.Forms.TextBox
$InputSluttdato.multiline        = $false
$InputSluttdato.width            = 200
$InputSluttdato.height           = 20
$InputSluttdato.location         = New-Object System.Drawing.Point(161,211)
$InputSluttdato.Font             = 'Microsoft Sans Serif,10'

$InputMobil                      = New-Object system.Windows.Forms.TextBox
$InputMobil.multiline            = $false
$InputMobil.text                 = "99999999"
$InputMobil.width                = 200
$InputMobil.height               = 20
$InputMobil.location             = New-Object System.Drawing.Point(160,177)
$InputMobil.Font                 = 'Microsoft Sans Serif,10'

$InputEtternavn                  = New-Object system.Windows.Forms.TextBox
$InputEtternavn.multiline        = $false
$InputEtternavn.width            = 200
$InputEtternavn.height           = 20
$InputEtternavn.location         = New-Object System.Drawing.Point(160,141)
$InputEtternavn.Font             = 'Microsoft Sans Serif,10'

$InputLeder                      = New-Object system.Windows.Forms.TextBox
$InputLeder.multiline            = $false
$InputLeder.width                = 200
$InputLeder.height               = 20
$InputLeder.location             = New-Object System.Drawing.Point(161,373)
$InputLeder.Font                 = 'Microsoft Sans Serif,10'

$InputLokasjon                   = New-Object system.Windows.Forms.TextBox
$InputLokasjon.multiline         = $false
$InputLokasjon.width             = 200
$InputLokasjon.height            = 20
$InputLokasjon.location          = New-Object System.Drawing.Point(160,337)
$InputLokasjon.Font              = 'Microsoft Sans Serif,10'

$InputStilling                   = New-Object system.Windows.Forms.TextBox
$InputStilling.multiline         = $false
$InputStilling.width             = 200
$InputStilling.height            = 20
$InputStilling.location          = New-Object System.Drawing.Point(161,305)
$InputStilling.Font              = 'Microsoft Sans Serif,10'

$InputAvdeling                   = New-Object system.Windows.Forms.TextBox
$InputAvdeling.multiline         = $false
$InputAvdeling.width             = 200
$InputAvdeling.height            = 20
$InputAvdeling.location          = New-Object System.Drawing.Point(160,276)
$InputAvdeling.Font              = 'Microsoft Sans Serif,10'

$InputFirma                      = New-Object system.Windows.Forms.TextBox
$InputFirma.multiline            = $false
$InputFirma.width                = 200
$InputFirma.height               = 20
$InputFirma.location             = New-Object System.Drawing.Point(160,243)
$InputFirma.Font                 = 'Microsoft Sans Serif,10'

$Tittel                          = New-Object system.Windows.Forms.Label
$Tittel.text                     = "AddAD for Entur"
$Tittel.BackColor                = "#f2d8ae"
$Tittel.AutoSize                 = $true
$Tittel.width                    = 25
$Tittel.height                   = 10
$Tittel.location                 = New-Object System.Drawing.Point(186,12)
$Tittel.Font                     = 'Pristina,30'

$CreateADUserButton              = New-Object system.Windows.Forms.Button
$CreateADUserButton.BackColor    = "#9b9b9b"
$CreateADUserButton.text         = "Create AD User"
$CreateADUserButton.width        = 219
$CreateADUserButton.height       = 53
$CreateADUserButton.location     = New-Object System.Drawing.Point(395,75)
$CreateADUserButton.Font         = 'Microsoft Sans Serif,15,style=Bold'
$CreateADUserButton.Add_Click({
    Create-User
})

$CheckSyncAzureButton            = New-Object system.Windows.Forms.Button
$CheckSyncAzureButton.BackColor  = "#9b9b9b"
$CheckSyncAzureButton.text       = "Check AzureAD Sync"
$CheckSyncAzureButton.width      = 219
$CheckSyncAzureButton.height     = 53
$CheckSyncAzureButton.location   = New-Object System.Drawing.Point(395,148)
$CheckSyncAzureButton.Font       = 'Microsoft Sans Serif,15,style=Bold'
$CheckSyncAzureButton.Add_Click({
    Azure-SyncForm
})

$CreateUserFromExcelButton                = New-Object system.Windows.Forms.Button
$CreateUserFromExcelButton.BackColor      = "#9b9b9b"
$CreateUserFromExcelButton.text           = "Import User from Excel file"
$CreateUserFromExcelButton.width          = 219
$CreateUserFromExcelButton.height         = 53
$CreateUserFromExcelButton.location       = New-Object System.Drawing.Point(395,226)
$CreateUserFromExcelButton.Font           = 'Microsoft Sans Serif,15,style=Bold'
$CreateUserFromExcelButton.Add_Click({
    ExcelMode
})

$ExitButton                      = New-Object system.Windows.Forms.Button
$ExitButton.BackColor            = "#9b9b9b"
$ExitButton.text                 = "Exit AddAD"
$ExitButton.width                = 219
$ExitButton.height               = 53
$ExitButton.location             = New-Object System.Drawing.Point(395,308)
$ExitButton.Font                 = 'Microsoft Sans Serif,15,style=Bold'

$ExitButton.Add_Click({
    $Form.Close()
})

$Form.Text                       = 'AddAD for Entur'
$Form.controls.AddRange(@($InputFornavn,$Fornavn,$Etternavn,$Stilling,$Firma,$Mobil,$Sluttdato,$Avdeling,$Lokasjon,$LederEpost,$InputSluttdato,$InputMobil,$InputEtternavn,$InputLeder,$InputLokasjon,$InputStilling,$InputAvdeling,$InputFirma,$Tittel,$CreateADUserButton,$CheckSyncAzureButton,$CreateUserFromExcelButton,$ExitButton))


