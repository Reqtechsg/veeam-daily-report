Asnp VeeamPSSnapin

$vm1 = Find-VBRViEntity -name "ULSDB01v"
$vm2 = Find-VBRViEntity -name "ULS_UAT_DB"
$vm3 = Find-VBRHvEntity -name "UTILSRV02v"
$vm_arr = $vm1, $vm2

$repo = Get-VBRBackupRepository -Name "NASSRV03"

Start-VBRZip -Entity $vm3 -BackupRepository $repo
Start-VBRZip -Entity $vm_arr -BackupRepository $repo

Get-ChildItem "\\NASSRV03\Backup-Servers\VEEAMSRV01\Repository\" -File | Where CreationTime -lt (Get-Date).AddDays(-7) | Remove-Item
