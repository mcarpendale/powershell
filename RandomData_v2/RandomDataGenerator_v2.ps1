<#
    --------------------------------------------------------------------------
                _____________________________________________________
       _,aad888P""""""""""Y888888888888888888888888888888P"""""""""""Y888baa,_
      aP'                     `""Ybaa,         ,aadP""'                     `Ya
     dP                             `"b,     ,d"'                             Yb
     8l                               8l_____8l                                8l
    [8l                               8l"""""8l                                8l]
     8l                              d8       8b                               8l
     8l                             dP/       \Yb                              8l
     8l                           ,dP/         \Yb,                            8l
     8l                        ,adP'/           \`Yba,                         8l
     Yb                     ,adP'                   `Yba,                     dP
      Yb                ,aadP'                         `Ybaa,                dP
       `Yb          ,aadP'                                 `Ybaa,          dP'
         `Ybaaaaad8P"'                                         `"Y8baaaaadP'
      
    --------------------------------------------------------------------------
    Script Description:

    This PowerShell script creates a specific number of folders in a specified directory, populates each of them with a random number of files, and generates these files with random sizes.

    Features of the script:

    1. The script defines the location where the folders will be created.
    2. It assigns possible file sizes in kilobytes and megabytes for randomly generated files.
    3. It checks the existing folders in the specified location and determines the highest existing folder number to avoid overwriting.
    4. The script then generates a specified number of new folders, incrementing the folder name based on the highest existing folder number.
    5. Within each newly created folder, it generates a random number of files (between 100 and 1000).
    6. Each generated file is assigned a random file size from the previously defined sizes.
    7. After the creation of each folder, the script calculates the total number of files in the folder and the total size of the folder, providing an output of these statistics.
    8. Finally, it calculates and outputs the total duration the script took to run.

    This script is useful for tasks such as unique data generation.

#>


# Defines the number of folders to be created
$run = 5

# Defines the location where the folders will be created
$location = "e:\random"

# Defines possible file sizes in kilobytes for randomly generated files
$randomsize = "1024", "2048", "3072", "4096", "5120", "6144", "7168", "8192", "9216", "10240", "11264", "12288", "13312"

# Defines possible file sizes in megabytes for randomly generated files
$MBrandomsize = "1024000", "2048000", "3072000", "4096000", "5120000", "6144000", "7168000", "8192000", "9216000", "10240000", "11264000","12288000", "13312000", "14336000", "15360000", "16384000", "17408000", "18432000", "19456000", "20480000", "21504000"

# Stores the current date and time as the start time for the script
$StartTime = Get-Date

# Gets all existing folders in the specified location and determines the highest existing folder number
$existingFolders = Get-ChildItem -Path $location -Directory | Select-Object -Property Name
$highestNumber = ($existingFolders.Name | Where-Object {$_ -match "^ran(\d{3})$"} | ForEach-Object {[int]($_ -replace 'ran', '')} | Sort-Object -Descending | Select-Object -First 1)

# Calculates the number for the next folder to be created
$nextFolderNumber = $highestNumber + 1

# Outputs the highest existing "ran" number
Write-Output "Highest existing 'ran' number: $highestNumber"

# Creates the specified number of folders and populates them with random files
for ($j=$nextFolderNumber; $j -lt ($run + $nextFolderNumber); $j++)
{
    # Creates a new folder name
    $folder = "ran" + "{0:D3}" -f $j
    mkdir $location\$folder | Out-Null

    # Generates a random number of files to be created in the folder
    $qty = Get-Random -Minimum 100 -Maximum 1000
    
    Write-Output "Creating Folder $folder with $qty random files"

    # Creates the specified number of random files
    for ($i=1; $i -le $qty; $i++)
    {
        # Generates a random file size
        $size = $MBrandomsize | Get-Random
        $out = new-object byte[] $size; (new-object Random).NextBytes($out)
        [IO.File]::WriteAllBytes("$location\$folder\file$i.txt", $out)
    }

    # Counts the number of files in the folder and calculates the total folder size
    $folderContent = Get-ChildItem -Path "$location\$folder"
    $fileCount = $folderContent.Count
    $folderSize = ($folderContent | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum) / 1GB
    Write-Output "Folder $folder Created - $([math]::Round($folderSize, 2))GB with $fileCount files"
}

# Stores the current date and time as the end time for the script
$EndTime = Get-Date

# Calculates the duration of the script in minutes
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

# Information Outputs
Write-Output "File creation complete"
Write-Output "StartTime: $StartTime"
Write-Output "EndTime: $EndTime"
Write-Output "Duration: $duration minutes"
