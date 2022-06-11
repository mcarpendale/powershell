$qty = 100
$location = "\\mc-wfsc-fs\random"
$folder = "ran0015"
$randomsize = "1024", "2048", "3072", "4096", "5120", "6144", "7168", "8192", "9216", "10240", "11264", "12288", "13312"
$MBrandomsize = "1024000", "2048000", "3072000", "4096000", "5120000", "6144000", "7168000", "8192000", "9216000", "10240000", "11264000","12288000", "13312000", "14336000", "15360000", "16384000", "17408000", "18432000", "19456000", "20480000", "21504000"
$2KB = "2048" 
$5MB = "5242880"

$StartTime = Get-Date

mkdir $location\$folder



for ($i=1; $i -le $qty; $i++)
{
    $size = $MBrandomsize | Get-Random
    $out = new-object byte[] $size; (new-object Random).NextBytes($out);           [IO.File]::WriteAllBytes("$location\$folder\file$i.txt", $out)
    #$out = new-object byte[] $2KB; (new-object Random).NextBytes($out);           [IO.File]::WriteAllBytes("$location\$folder\file$i.txt", $out)
}


$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

Write-Output "File creation compelete"
Write-Output "StartTime: $StartTime"
Write-Output "EndTime: $EndTime"
Write-Output "Duration: $duration minutes" 
