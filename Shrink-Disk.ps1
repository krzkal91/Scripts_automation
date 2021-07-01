<#

.SYNOPSIS

Script will shrink the existing OS disk of Azure VM to a given size 

.PARAMETER resourceGroupName
The resourceGroupName where VM is located

.PARAMETER vmName
The name of the VM that will be the object of shrinking

.PARAMETER storageAccountName
The name of the temporary storage account used for operation

.PARAMETER diskSizeGB
The number of GBs to be set for the new disk

.PARAMETER subscriptionName
The name of the subscription to be used

#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory=$true)]
    [string] $resourceGroupName = "RG-sourceVM",

    [Parameter(Mandatory=$true)]
    [string] $vmName = "VHDSourceVM",

    [Parameter(Mandatory=$true)]
    [string] $diskSizeGB = 64,

    [Parameter(Mandatory=$false)]
    [string] $storageAccountName = "saforvhd999111",

    [Parameter(Mandatory=$true)]
    [string] $subscriptionName = "Azure Subscription"
)
function Shrink-Disk(
    [string] $resourceGroupName,
    [string] $vmName,
    [int]    $diskSizeGB,
    [string] $storageAccountName,
    [string] $subscriptionName
) {

$VM = Get-AzureRmVm -Name $VMName -ResourceGroupName $resourceGroupName

$Disk = $VM.StorageProfile.OsDisk
$DiskID = $Disk.Id

# Get Disk Name from Disk
$DiskName = $Disk.Name

write-output "Stopping the VM"
$VM | Stop-AzureRmVM -Force

# Get SAS URI for the Managed disk
write-output "Getting SAS URI for the Managed disk"
$SAS = Grant-AzureRmDiskAccess -ResourceGroupName $resourceGroupName -DiskName $DiskName -Access 'Read' -DurationInSecond 600000;

#Name of the storage container where the downloaded snapshot will be stored
$storageContainerName = 'shrink'

#Provide the name of the VHD file to which snapshot will be copied.
$destinationVHDFileName = "$($VM.StorageProfile.OsDisk.Name).vhd"

#Create the context for the storage account which will be used to copy snapshot to the storage account 
write-output "Creating the context for the storage account"
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$destinationContext = $StorageAccount.Context
$container = New-AzureRmStorageContainer -Name $storageContainerName -PublicAccess Container -StorageAccountName $storageAccountName -ResourceGroupName $resourceGroupName

#Copy the snapshot to the storage account and wait for it to complete
write-output "Starting the copying to the storage account"
Start-AzureStorageBlobCopy -AbsoluteUri $SAS.AccessSAS -DestContainer $storageContainerName -DestBlob $destinationVHDFileName -DestContext $destinationContext
while(($state = Get-AzureStorageBlobCopyState -Context $destinationContext -Blob $destinationVHDFileName -Container $storageContainerName).Status -ne "Success") { $state; Start-Sleep -Seconds 20 }
$state

# Revoke SAS token
write-output "Revoking the disk access"
Revoke-AzureRmDiskAccess -ResourceGroupName $resourceGroupName -DiskName $DiskName

# Emtpy disk to get footer from
$emptydiskforfootername = "$($VM.StorageProfile.OsDisk.Name)-empty.vhd"

write-output "Creating the empty disk config and the empty disk"
$diskConfig = New-AzureRmDiskConfig `
    -Location $VM.Location `
    -CreateOption Empty `
    -DiskSizeGB $DiskSizeGB `
    -AccountType StandardSSD_LRS

$dataDisk = New-AzureRmDisk `
    -ResourceGroupName $resourceGroupName `
    -DiskName $emptydiskforfootername `
    -Disk $diskConfig

write-output "Attaching the empty disk as data disk"
$VM = Add-AzureRmVMDataDisk `
    -VM $VM `
    -Name $emptydiskforfootername `
    -CreateOption Attach `
    -ManagedDiskId $dataDisk.Id `
    -Lun 5

Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $VM

write-output "Stopping the VM"
$VM | Stop-AzureRmVM -Force


# Get SAS token for the empty disk
write-output "Getting the SAS token for the empty disk"
$SAS = Grant-AzureRmDiskAccess -ResourceGroupName $resourceGroupName -DiskName $emptydiskforfootername -Access 'Read' -DurationInSecond 600000;

# Copy the empty disk to blob storage
write-output "Starting to copy the so called empty disk to blob"
Start-AzureStorageBlobCopy -AbsoluteUri $SAS.AccessSAS -DestContainer $storageContainerName -DestBlob $emptydiskforfootername -DestContext $destinationContext
while(($state = Get-AzureStorageBlobCopyState -Context $destinationContext -Blob $emptydiskforfootername -Container $storageContainerName).Status -ne "Success") { $state; Start-Sleep -Seconds 20 }
$state

# Revoke SAS token
write-output "Revoking the access for the disk"
Revoke-AzureRmDiskAccess -ResourceGroupName $resourceGroupName -DiskName $emptydiskforfootername

# Remove temp empty disk
write-output "Removing the empty disk and deleting"
Remove-AzureRmVMDataDisk -VM $VM -DataDiskNames $emptydiskforfootername
Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $VM

# Delete temp disk
Remove-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $emptydiskforfootername -Force;

# Get the blobs
$emptyDiskblob = Get-AzureStorageBlob -Context $destinationContext -Container $storageContainerName -Blob $emptydiskforfootername
$osdisk = Get-AzureStorageBlob -Context $destinationContext -Container $storageContainerName -Blob $destinationVHDFileName

$footer = New-Object -TypeName byte[] -ArgumentList 512
write-output "Get footer of empty disk"

$downloaded = $emptyDiskblob.ICloudBlob.DownloadRangeToByteArray($footer, 0, $emptyDiskblob.Length - 512, 512)

$osDisk.ICloudBlob.Resize($emptyDiskblob.Length)
$footerStream = New-Object -TypeName System.IO.MemoryStream -ArgumentList (,$footer)
write-output "Write footer of empty disk to OSDisk"
$osDisk.ICloudBlob.WritePages($footerStream, $emptyDiskblob.Length - 512)

Write-Output -InputObject "Removing empty disk blobs"
$emptyDiskblob | Remove-AzureStorageBlob -Force


#Provide the name of the Managed Disk
$NewDiskName = "$DiskName" + "-new"

#Create the new disk with the same SKU as the current one
$accountType = 'StandardSSD_LRS'

# Get the new disk URI
$vhdUri = $osdisk.ICloudBlob.Uri.AbsoluteUri

# Specify the disk options
write-output "Specifying the new target disk config and building the disk"
$diskConfig = New-AzureRmDiskConfig -AccountType $accountType -Location $VM.location -DiskSizeGB $DiskSizeGB -SourceUri $vhdUri -CreateOption Import -StorageAccountId $StorageAccount.Id

#Create Managed disk
$NewManagedDisk = New-AzureRmDisk -DiskName $($DiskName + "new") -Disk $diskConfig -ResourceGroupName $resourceGroupName
$NewManagedDisk = Get-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $($DiskName + "new")
$VM = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $VMName
$VM | Stop-AzureRmVM -Force

# Set the VM configuration to point to the new disk  
write-output "Updating the VM with the target OS disk created"
Set-AzureRmVMOSDisk -VM $VM -ManagedDiskId $NewManagedDisk.Id -Name $NewManagedDisk.Name

# Update the VM with the new OS disk
Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $VM

write-output "Starting the VM..."
$VM | Start-AzureRmVM

write-output "...giving it some time to come to its senses :)"
start-sleep 180
# Please check the VM is running before proceeding with the below tidy-up steps

# Delete old Managed Disk
write-output "Deleting the old managed disk and blob storage"
Remove-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $DiskName -Force;

# Delete old blob storage
$osdisk | Remove-AzureStorageBlob -Force


}

Shrink-Disk -resourceGroupName $resourceGroupName -vmName $vmName -diskSizeGB $diskSizeGB -storageAccountName $storageAccountName -subscriptionName $subscriptionName