# Powershell script to create RANDOM data at various sizes
This pwsh file will create random file data in the location and folder of your choice


## Pre-Requisites
### Variables
Update the ``.ps1`` files with the your variable information

``$qty``      : the quantity of files you want to create

``$location`` : the lcoation where you will be creating the random data

``$folder``   : the folder used to house the random data

```pwsh
$qty = 100
$location = "\\mc-wfsc-fs\random"
$folder = "ran0015" 

  ```
### Size for File
This script is set to create random MB sized files. You can adjust to KB or a set size

Adjust this section of the pwsh file
```pwsh
 $size = $MBrandomsize | Get-Random 
```
``$randomsize``

``$MBrandomsize``

``$2KB``

``$5MB``

If you want to adjsut the ``MB`` of ``KB`` Sizing - edit these lines
```pwsh
 $randomsize = "1024", "2048", "3072", "4096", "5120", "6144", "7168", "8192", "9216", "10240", "11264", "12288", "13312"
$MBrandomsize = "1024000", "2048000", "3072000", "4096000", "5120000", "6144000", "7168000", "8192000", "9216000", "10240000", "11264000","12288000", "13312000", "14336000", "15360000", "16384000", "17408000", "18432000", "19456000", "20480000", "21504000"
```
