# Powershell script to create RANDOM data at various sizes - version 2
This PowerShell script creates a specific number of folders in a specified directory, populates each of them with a random number of files, and generates these files with random sizes.

    This script is useful for tasks such as unique data generation.

## Features of the script:
1. The script defines the location where the folders will be created. `$location`
2. It assigns possible file sizes in kilobytes and megabytes for randomly generated files. `$MBrandomsize` or ``$randomsize``
3. It checks the existing folders in the specified location and determines the highest existing folder number to avoid overwriting.
4. The script then generates a specified number of new folders, incrementing the folder name based on the highest existing folder number. ``$run`` 
5. Within each newly created folder, it generates a random number of files (between 100 and 1000). ``$qty = Get-Random -Minimum 100 -Maximum 1000``
6. Each generated file is assigned a random file size from the previously defined sizes.
7. After the creation of each folder, the script calculates the total number of files in the folder and the total size of the folder, providing an output of these statistics.
8. Finally, it calculates and outputs the total duration the script took to run.



## Variables
Update the ``.ps1`` files with the your variable information

``$run``      : Defines the number of folders to be created

``$location`` : Defines the location where the folders will be created


```pwsh
# Defines the number of folders to be created
$run = 5

# Defines the location where the folders will be created
$location = "e:\random"
```

### Size for Files
This script is set to create random `MB` sized files. You can adjust to `KB`

Adjust this section of the pwsh file
```pwsh
        # Generates a random file size
        $size = $MBrandomsize | Get-Random
```
Replace `$MBrandomsize` with ``$randomsize``

