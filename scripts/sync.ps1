<#
.DESCRIPTION
A Runbook example that automatically creates incremental backups of an Azure Files system on a customer-defined schedule and stores the backups in a separate storage account.
It does so by leveraging AzCopy with the sync parameter, which is similar to Robocopy /MIR. Only changes will be copied with every backup, and any deletions on the source will be mirrored on the target.
In this example, AzCopy is running in a Container inside an Azure Container Instance using Service Principal in Azure AD.

.NOTES
Filename : SyncBetweenTwoFileShares
Author1 : Sibonay Koo (Microsoft PM)
Author2 : Charbel Nemnom (Microsoft MVP/MCT)
Version : 2.1
Date : 13-February-2021
Updated : 18-April-2022
Tested : Az.ContainerInstance PowerShell module version 2.1 and above

.LINK
To provide feedback or for further assistance please email: azurefiles[@]microsoft.com
#>

# Param (
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $sourceAzureSubscriptionId,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $sourceStorageAccountRG,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $targetStorageAccountRG,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $sourceStorageAccountName,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $targetStorageAccountName,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $sourceStorageFileShareName,
#   [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
#   [String] $targetStorageFileShareName
# )

$sourceAzureSubscriptionId  = "d0f6eb41-3e86-48da-bc57-893eab20796f"
$sourceStorageAccountRG 	= "rg-sync-dev-uks-001"
$targetStorageAccountRG     = "rg-sync-dev-ukw-001"
$sourceStorageAccountName   = "stsyncdevuks001"
$targetStorageAccountName   = "stsyncdevukw001"
$sourceStorageFileShareName = "source"
$targetStorageFileShareName = "target"

# Azure File Share maximum snapshot support limit by the Azure platform is 200
[Int]$maxSnapshots = 200

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity (automation account)
$AzContext = (Connect-AzAccount -Identity).context
$AzContext = Set-AzContext -SubscriptionName $AzContext.subscription -DefaultProfile $AzContext
# Connect-AzAccount -Identity

# SOURCE Azure Subscription
# Select-AzSubscription -SubscriptionId $sourceAzureSubscriptionId

#! Source Storage Account in the primary region
# Get Source Storage Account Key
$sourceStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $sourceStorageAccountRG -Name $sourceStorageAccountName).Value[0]

# Set Azure Storage Context
$sourceContext = New-AzStorageContext -StorageAccountKey $sourceStorageAccountKey -StorageAccountName $sourceStorageAccountName

# List the current snapshots on the source share
$snapshots = Get-AzStorageShare -Context $sourceContext.Context | Where-Object { $_.Name -eq $sourceStorageFileShareName -and $_.IsSnapshot -eq $true }

# Delete the oldest (1) manual snapshot in the source share if have 180 or more snapshots (Azure Files snapshot limit is 200)
# This leaves a buffer such that there can always be 6 months of daily snapshots and 10 yearly snapshots taken via Azure Backup
# You may need to adjust this buffer based on your snapshot retention policy
If ((($snapshots.count) + 20) -ge $maxSnapshots) {
  $manualSnapshots = $snapshots | where-object { $_.ShareProperties.Metadata.Initiator -eq "Manual" }
  Remove-AzStorageShare -Share $manualSnapshots[0].CloudFileShare -Force
}

# Take manual snapshot on the source share
# When taking a snapshot using PowerShell, CLI or from the Portal, the snapshot's metadata is set to a key-value pair with the key being "Manual"
# The value of "AzureBackupProtected" is set to "True" or "False" depending on whether Azure Backup is enabled
$sourceShare = Get-AzStorageShare -Context $sourceContext.Context -Name $sourceStorageFileShareName
$sourceSnapshot = $sourceShare.CloudFileShare.Snapshot()

# Generate source file share SAS URI
$sourceShareSASURI = New-AzStorageShareSASToken -Context $sourceContext -ExpiryTime(get-date).AddDays(1) -FullUri -ShareName $sourceStorageFileShareName -Permission rl
# Set source file share snapshot SAS URI
$sourceSnapSASURI = $sourceSnapshot.SnapshotQualifiedUri.AbsoluteUri + "&" + $sourceShareSASURI.Split('?')[-1]

#! TARGET Storage Account in a different region
# Get Target Storage Account Key
$targetStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $targetStorageAccountRG -Name $targetStorageAccountName).Value[0]

# Set Target Azure Storage Context
$destinationContext = New-AzStorageContext -StorageAccountKey $targetStorageAccountKey -StorageAccountName $targetStorageAccountName

# Generate target SAS URI
$targetShareSASURI = New-AzStorageShareSASToken -Context $destinationContext -ExpiryTime(get-date).AddDays(1) -FullUri -ShareName $targetStorageFileShareName -Permission rwl

# Check if target file share contains data
$targetFileShare = Get-AzStorageFile -Sharename $targetStorageFileShareName -Context $destinationContext.Context

# If target share already contains data, use AzCopy sync to sync data from source to target
# Else if target share is empty, use AzCopy copy as it will be more efficient
# By default, the replicated files that you deleted from the source does not get deleted on the destination.
# The deletion on the destination is optional because some customers want to keep them as backup in the DR location.
# If you want to delete the files, then you want to add the " --delete-destination true" flag to the $command below.
# The "--delete-destination" defines whether to delete extra files from the destination that are not present at the source.
if ($targetFileShare) {
  $command = "azcopy", "sync", $sourceSnapSASURI, $targetShareSASURI, "--preserve-smb-info", "--preserve-smb-permissions", "--recursive"
}
Else {
  $command = "azcopy", "copy", $sourceSnapSASURI, $targetShareSASURI, "--preserve-smb-info", "--preserve-smb-permissions", "--recursive"
}

# The container image (peterdavehello/azcopy:latest) is publicly available on Docker Hub and has the latest AzCopy version installed
# You could also create your own private container image and use it instead
# When you create a new container instance, the default compute resources are set to 1vCPU and 1.5GB RAM
# We recommend starting with 2vCPU and 4GB memory for larger file shares (E.g. 3TB)
# You may need to adjust the CPU and memory based on the size and churn of your file share
# The container will be created in the $location variable based on the source storage account location. Adjust if needed.
$location = (Get-AzResourceGroup -Name $sourceStorageAccountRG).location
$containerGroupName = "syncafsdrjob"

# Set the AZCOPY_BUFFER_GB value at 2 GB which would prevent the container from crashing.
$envVars = New-AzContainerInstanceEnvironmentVariableObject -Name "AZCOPY_BUFFER_GB" -Value "2"

# Create Azure Container Instance Object
$container = New-AzContainerInstanceObject `
  -Name $containerGroupName `
  -Image "peterdavehello/azcopy:latest" `
  -RequestCpu 2 `
  -RequestMemoryInGb 4 `
  -Command $command `
  -EnvironmentVariable $envVars

# Create Azure Container Group and run the AzCopy job
$containerGroup = New-AzContainerGroup -ResourceGroupName $sourceStorageAccountRG `
  -Name $containerGroupName `
  -Container $container `
  -OsType Linux `
  -Location $location `
  -RestartPolicy never

# List the current snapshots on the target share
$snapshots = Get-AzStorageShare `
  -Context $destinationContext.Context | `
  Where-Object { $_.Name -eq $targetStorageFileShareName -and $_.IsSnapshot -eq $true }

# Delete the oldest (1) manual snapshot in the target share if have 190 or more snapshots (Azure Files backup snapshot limit is 200)
If ((($snapshots.count) + 10) -ge $maxSnapshots) {
  $manualSnapshots = $snapshots | where-object { $_.ShareProperties.Metadata.Initiator -eq "Manual" }
  Remove-AzStorageShare -Share $manualSnapshots[0].CloudFileShare -Force
}

# Take manual snapshot on the target share
# When taking a snapshot using PowerShell, CLI or from the Portal, the snapshot's metadata is set to a key-value pair with the key being "Manual"
# The value of "AzureBackupProtected" is set to "True" or "False" depending on whether Azure Backup is enabled
$targetShare = Get-AzStorageShare -Context $destinationContext.Context -Name $targetStorageFileShareName
$targetShareSnapshot = $targetShare.CloudFileShare.Snapshot()

Write-Output ("")