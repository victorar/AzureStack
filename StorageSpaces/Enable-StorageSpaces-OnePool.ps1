param (
    [Parameter(Mandatory=$true)][int][ValidateRange(1,32)]$vDisks    
)

$physicalDisks = Get-StorageSubSystem -FriendlyName "Windows Storage*" | Get-PhysicalDisk -CanPool $True 
$spacesPool = New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $physicalDisks
$vDiskCapacity = ($spacesPool.Size) / $vDisks


For ($i=0; $i -lt $vDisks; $i++){
    if ($i -eq $vDisks -1){
        $spacesPool | New-VirtualDisk -FriendlyName "DataFiles" -Interleave 65536 -NumberOfColumns $physicalDisks.Count -ResiliencySettingName Simple -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataFiles" -AllocationUnitSize 65536    
        }
        else{
        $spacesPool | New-VirtualDisk -FriendlyName "DataFiles" -Interleave 65536 -NumberOfColumns $physicalDisks.Count -ResiliencySettingName Simple -Size $vDiskCapacity | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataFiles" -AllocationUnitSize 65536    
    }
}



