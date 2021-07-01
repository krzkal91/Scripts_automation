<#

.SYNOPSIS
Script will create a snapshot of a VMs OS disk

.DESCRIPTION
Script will create a snapshot of a VMs OS disk
and then transcribe the Snapshot to a form
of VHD storing it as a BLOB on a storage account.
REQUIRES existing SA with a container PRIOR to this operation

.PARAMETER resourceGroupName
The resourceGroupName where VM is located

.PARAMETER storageResourceGroupName
The resource group name where SA is located (will create if not exists)
By default - same as VMs RG

.PARAMETER vmName
The name of the VM that will be the source for VHD

.PARAMETER Location
The location of the VM in question

.PARAMETER snapshotName
The name of the snapshot to be set

.PARAMETER storageAccountName
The name of the storage account to be set

.PARAMETER subscriptionName
The name of the subscription to be used

.PARAMETER storageContainerName
The name of the target container for storing the vhd

#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory=$true)]
    [string] $resourceGroupName = "RG-sourceVM",

    [Parameter(Mandatory=$false)]
    [string] $storageResourceGroupName = "RG-sourceVM",

    [Parameter(Mandatory=$true)]
    [string] $vmName = "VHDSourceVM",

    [Parameter(Mandatory=$true)]
    [string] $Location = "North Europe",

    [Parameter(Mandatory=$false)]
    [string] $snapshotName = "snapshot-sourceVM-forVHD",

    [Parameter(Mandatory=$false)]
    [string] $storageAccountName = "saforvhd999111",

    [Parameter(Mandatory=$false)]
    [string] $imageName = "generic-imageName.vhd",

    [Parameter(Mandatory=$true)]
    [string] $subscriptionName = "Azure Subscription",

    [Parameter(Mandatory=$true)]
    [string] $storageContainerName = "imagecontainer"
)
function Create-VHD(
    [string] $resourceGroupName,
    [string] $storageResourceGroupName,
    [string] $vmName,
    [string] $Location,
    [string] $snapshotName,
    [string] $storageAccountName,
    [string] $subscriptionName,
    [string] $storageContainerName
) {

    # Setting subscription Context
    $loggingPrefix = "Create-VHD.ps1 ::: "
    $subid = (Get-AzureRMSubscription -SubscriptionName $subscriptionName).id
    Write-Host "$loggingPrefix Setting Subscription context to $subscriptionName with id $subid" -BackgroundColor Yellow
    Set-AzureRMContext -SubscriptionId $subid

    # Checking VM status and stopping if not deallocated
    $vm = Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName
    Write-Host "$loggingPrefix VM selected as source of Snapshot $vmName" -BackgroundColor Yellow

    Write-Host "$loggingPrefix CHecking VM status of $vmName" -BackgroundColor Yellow
    if((Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName -Status).PowerState -ne "VM deallocated") {
        Write-Host "$loggingPrefix Status of $vmName is not deallocated" -BackgroundColor Yellow
        if((Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName -Status).PowerState -eq "VM running") {
            Write-Host "$loggingPrefix Status of $vmName is running. Stopping VM" -BackgroundColor Yellow
            Stop-AzureRMVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
            while((Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName -Status).PowerState -ne "VM deallocated") {
                Start-Sleep -s 5
                Write-Host "$loggingPrefix Status of $vmName is still not deallocated. Waiting for deallocation" -BackgroundColor Yellow
            }
        }
    }
    if((Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName -Status).PowerState -eq "VM deallocated") {
        Write-Host "$loggingPrefix Status of $vmName is deallocated" -BackgroundColor Yellow
    }

    # Taking the disk snapshot
    $vmOSDisk=(Get-AzureRMVm -ResourceGroupName $resourceGroupName -Name $vmName).StorageProfile.OsDisk.Name
    $Disk = Get-AzureRMDisk -ResourceGroupName $resourceGroupName -DiskName $vmOSDisk
    $SnapshotConfig = New-AzureRMSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location
    Write-Host "$loggingPrefix Starting snapshot of $($Disk.Name)" -BackgroundColor Yellow
    $snapshot = New-AzureRMSnapshot -Snapshot $SnapshotConfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

    $sasExpiryDuration=3600

    # Building storage context
    Write-Host "$loggingPrefix Building storage context"
    $key = (Get-AzureRMStorageAccountKey -ResourceGroupName $storageResourceGroupName -Name $storageAccountName).Value[0]
    $sas = (Grant-AzureRMSnapshotAccess -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName -DurationInSecond $sasExpiryDuration -Access 'Read').AccessSAS
    $storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key

    #Copying the VHD to the container
    Write-Host "$loggingPrefix Starting to copy VHD to $storageContainerName located on $storageAccountName." -BackgroundColor Yellow
    Start-AzureStorageBlobCopy -AbsoluteUri $sas -DestContainer $storageContainerName -DestBlob $imageName -DestContext $storageContext
    while($true){
        $status = (Get-AzureStorageBlobCopyState -Blob $imageName -Container $storageContainerName -Context $storageContext).Status
        Write-Host "$loggingPrefix Status of the copy is: $status." -BackgroundColor Yellow
        if ($status -eq "Pending") {
            Write-Host "$loggingPrefix Awaiting the copy job to be finished. Sleeping for 10s" -BackgroundColor Red
            Start-Sleep -s 10
        }
        if ($status -eq "Success") {
            Write-Host "$loggingPrefix The copy job finished. Status is $status" -BackgroundColor Green
            break
        }
    }

    Revoke-AzureRmSnapshotAccess -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 
}


Create-VHD -resourceGroupName $resourceGroupName -storageResourceGroupName $storageResourceGroupName -vmName $vmName -Location $Location -snapshotName $snapshotName -storageAccountName $storageAccountName -subscriptionName $subscriptionName