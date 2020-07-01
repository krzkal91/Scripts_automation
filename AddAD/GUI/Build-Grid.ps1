
function Build-Grid {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)]
    [System.Collections.ArrayList]$dataSource
    )


    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $UserLicensesForm                = New-Object system.Windows.Forms.Form
    $UserLicensesForm.ClientSize     = '1269,951'
    $UserLicensesForm.text           = "User AzureAD/O365 Status"
    $UserLicensesForm.BackColor      = "#986c1b"
    $UserLicensesForm.TopMost        = $true

    $LicensesDataGridView            = New-Object system.Windows.Forms.DataGridView
    $LicensesDataGridView.DataSource = $dataSource
    $LicensesDataGridView.Dock       = [System.Windows.Forms.DockStyle]::Fill
    $LicensesDataGridView.text       = "UserLicenses for $upn"
    $LicensesDataGridView.AllowUserToResizeColumns = $true
    $LicensesDataGridView.BackColor  = "#898253"
    $LicensesDataGridView.location   = New-Object System.Drawing.Point(16,15)

    $LicensesDataGridView.ReadOnly   = $true
    $LicensesDataGridView.RowHeadersVisible = $false
    $LicensesDataGridView.Size       = '1000,900'
    $LicensesDataGridView.AutoSizeColumnsMode = 'Fill'


    $UserLicensesForm.controls.AddRange(@($LicensesDataGridView))

    $UserLicensesForm.ShowDialog() 
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null


}