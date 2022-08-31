$source_rg = "rg-sync-dev-uks-001"
$target_rg = "rg-sync-dev-ukw-001"

### STORAGE ACCOUNTS ###
$source_sa = Get-AzStorageAccount -ResourceGroupName $source_rg
$target_sa = Get-AzStorageAccount -ResourceGroupName $target_rg

### KEYS ###
$source_key = (Get-AzStorageAccountKey -ResourceGroupName $source_rg -Name $source_sa.StorageAccountName).Value[0]
$target_key = (Get-AzStorageAccountKey -ResourceGroupName $target_rg -Name $target_sa.StorageAccountName).Value[0]

### CONTEXT ###
$source_context = New-AzStorageContext -StorageAccountName $source_sa.StorageAccountName -StorageAccountKey $source_key.Value
$target_context = New-AzStorageContext -StorageAccountName $target_sa.StorageAccountName -StorageAccountKey $target_key.Value

$source_share = Get-AzStorageShare -Context $source_context
$target_share = Get-AzStorageShare -Context $target_context


<#
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Target,

    [Parameter(Mandatory = $true)]
    [int]$ParallelCount,

    [Parameter(Mandatory = $false)]
    [string]$File)


$ErrorActionPreference = 'Stop'

# Redefine the wrapper over STDOUT to use UTF8. Node expects UTF8 by default.
$stdout = [System.Console]::OpenStandardOutput()
$utf8 = New-Object System.Text.UTF8Encoding($false) # do not emit BOM
$writer = New-Object System.IO.StreamWriter($stdout, $utf8)
[System.Console]::SetOut($writer)

# All subsequent output must be written using [System.Console]::WriteLine(). In
# PowerShell 4, Write-Host and Out-Default do not consider the updated stream writer.

if (!$File) {
    $File = "*";
    $CopySubFoldersOption = "/E"
}

# Print the ##command. The /MT parameter is only supported on 2008 R2 and higher.
if ($ParallelCount -gt 1) {
    [System.Console]::WriteLine("##[command]robocopy.exe $CopySubFoldersOption /COPY:DA /NP /R:3 /MT:$ParallelCount `"$Source`" `"$Target`" `"$File`"")
}
else {
    [System.Console]::WriteLine("##[command]robocopy.exe $CopySubFoldersOption /COPY:DA /NP /R:3 `"$Source`" `"$Target`" `"$File`"")
}

# The $OutputEncoding variable instructs PowerShell how to interpret the output
# from the external command.
$OutputEncoding = [System.Text.Encoding]::Default

#             Usage :: ROBOCOPY source destination [file [file]...] [options]
#            source :: Source Directory (drive:\path or \\server\share\path).
#       destination :: Destination Dir  (drive:\path or \\server\share\path).
#              file :: File(s) to copy  (names/wildcards: default is "*.*").
#                /E :: copy subdirectories, including Empty ones.
# /COPY:copyflag[s] :: what to COPY for files (default is /COPY:DAT).
#                      (copyflags : D=Data, A=Attributes, T=Timestamps).
#                      (S=Security=NTFS ACLs, O=Owner info, U=aUditing info).
#               /NP :: No Progress - don't display percentage copied.
#			/MT[:n] :: Do multi-threaded copies with n threads (default 8).
#                       n must be at least 1 and not greater than 128.
#                       This option is incompatible with the /IPG and /EFSRAW options.
#                      Redirect output using /LOG option for better performance.
#              /R:n :: number of Retries on failed copies: default 1 million.
#
# Note, the output from robocopy needs to be iterated over. Otherwise PowerShell.exe
# will launch the external command in such a way that it inherits the streams.
#
# Note, the /MT parameter is only supported on 2008 R2 and higher.
if ($ParallelCount -gt 1) {
    & robocopy.exe $CopySubFoldersOption /COPY:DA /NP /R:3 /MT:$ParallelCount $Source $Target $File 2>&1 |
        ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            [System.Console]::WriteLine($_.Exception.Message)
        }
        else {
            [System.Console]::WriteLine($_)
        }
    }
}
else {
    & robocopy.exe $CopySubFoldersOption /COPY:DA /NP /R:3 $Source $Target $File 2>&1 |
        ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            [System.Console]::WriteLine($_.Exception.Message)
        }
        else {
            [System.Console]::WriteLine($_)
        }
    }
}

[System.Console]::WriteLine("##[debug]robocopy exit code '$LASTEXITCODE'")
[System.Console]::Out.Flush()
if ($LASTEXITCODE -ge 8) {
    exit $LASTEXITCODE
}
#>