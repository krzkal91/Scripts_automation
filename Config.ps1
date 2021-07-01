<#

.SYNOPSIS
Script for initial Windows Server VM configuration - used as CSE

.DESCRIPTION
Script for initial Windows Server VM configuration - used as CSE
The script performs 3 tasks:
1. Resizes the C partition, as the disk size will be shrinked in one of the later steps
2. Performs the initial OS update post VM provisioning
3. Enables WinRM remoting and installs a cerfificate - hardcoded for North Europe region, but can be changed/parameterized

#>


$ErrorActionPreference = 'Stop'
$InformationPreference = "Continue"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$osPartition = Get-Partition -DriveLetter "C"
Resize-Partition -DiskNumber $osPartition.DiskNumber -PartitionNumber $osPartition.PartitionNumber -Size (63GB)
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -Value 3389 -Force

$Criteria = "IsInstalled=0 and Type='Software'"
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchResult = $Searcher.Search($Criteria).Updates
if ($SearchResult.Count -eq 0) {
    exit
} else {
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $SearchResult
    $Downloader.Download()
    $Installer = New-Object -ComObject Microsoft.Update.Installer
    $Installer.Updates = $SearchResult
    $Result = $Installer.Install()
}

Enable-PSRemoting -Force
$name = $($env:COMPUTERNAME + ".northeurope.cloudapp.azure.com")
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $name -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$name""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command

Enable-WSManCredSSP -Role Server -Force

New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name AllowFreshCredentialsWhenNTLMOnly -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name 1 -Value * -PropertyType String