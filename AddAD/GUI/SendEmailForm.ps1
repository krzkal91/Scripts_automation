
## Send email question form ##

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$SendEmailQuestionForm           = New-Object system.Windows.Forms.Form
$SendEmailQuestionForm.ClientSize  = '482,171'
$SendEmailQuestionForm.text      = "E-mail"
$SendEmailQuestionForm.BackColor  = "#f2d8ae"
$SendEmailQuestionForm.TopMost   = $True
$SendEmailQuestionForm.StartPosition = 'CenterScreen'


$QuestionEmail                   = New-Object system.Windows.Forms.Label
$QuestionEmail.text              = "Ønsker du at automatisk varsel til HR og leder blir sendt?"
$QuestionEmail.AutoSize          = $true
$QuestionEmail.width             = 25
$QuestionEmail.height            = 10
$QuestionEmail.location          = New-Object System.Drawing.Point(77,56)
$QuestionEmail.Font              = 'Microsoft Sans Serif,10'

$EmailResponseJaButton                 = New-Object system.Windows.Forms.Button
$EmailResponseJaButton.BackColor       = "#9b9b9b"
$EmailResponseJaButton.text            = "Ja, varsle HR og leder"
$EmailResponseJaButton.width           = 209
$EmailResponseJaButton.height          = 30
$EmailResponseJaButton.location        = New-Object System.Drawing.Point(35,109)
$EmailResponseJaButton.Font            = 'Microsoft Sans Serif,10,style=Bold'
$EmailResponseJaButton.ForeColor       = ""

$EmailResponseNeiButton                = New-Object system.Windows.Forms.Button
$EmailResponseNeiButton.BackColor      = "#9b9b9b"
$EmailResponseNeiButton.text           = "Nei, takk"
$EmailResponseNeiButton.width          = 209
$EmailResponseNeiButton.height         = 30
$EmailResponseNeiButton.location       = New-Object System.Drawing.Point(259,108)
$EmailResponseNeiButton.Font           = 'Microsoft Sans Serif,10,style=Bold'
$EmailResponseNeiButton.ForeColor      = ""

$SendEmailQuestionForm.controls.AddRange(@($QuestionEmail,$EmailResponseJaButton,$EmailResponseNeiButton))
$EmailResponseJaButton.Add_Click({
    Send-Mail
    $SendEmailQuestionForm.Close()
})
$EmailResponseNeiButton.Add_Click({
    $SendEmailQuestionForm.Close()
})
