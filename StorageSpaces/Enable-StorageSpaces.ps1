
$vDisks = 8
$vhdsPervDisk = 4

$PhysicalDisks = Get-StorageSubSystem -FriendlyName "Windows Storage*" | Get-PhysicalDisk -CanPool $True 

if ($vDisks * $vhdsPervDisk -gt $PhysicalDisks.Count){
    Write-Host "The number of virtual disks required ($vDisks) and the number of VHDs per virtual disk ($vhdsPervDisk) is greather than the total VHDs available on this VM ($PhysicalDisks.Count)"
    Write-Host "Stopping script execution"
    Exit
}

$counter= 0
do{
    $poolDisks = @()    
    for ($i=0; $i -lt $vhdsPervDisk ; $i++){
        $poolDisks += $PhysicalDisks[$i + $counter]
    }
    $spacesPool = New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $poolDisks
    $spacespool | New-VirtualDisk -FriendlyName "DataFiles" -Interleave 65536 -NumberOfColumns $vhdsPervDisk -ResiliencySettingName Simple -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataFiles" -AllocationUnitSize 65536
    $counter= $counter + $i

} while ($counter -lt $PhysicalDisks.Count)



#New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks | New-VirtualDisk -FriendlyName "DataFiles" -Interleave 65536 -NumberOfColumns $PhysicalDisks.Count -ResiliencySettingName Simple -UseMaximumSize | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataFiles" -AllocationUnitSize 65536
