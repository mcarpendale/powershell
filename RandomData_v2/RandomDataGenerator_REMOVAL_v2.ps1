<#
    --------------------------------------------------------------------------
    Art by Marcin Glinski
                                              _.gd8888888bp._
                                            .g88888888888888888p.
                                        .d8888P""       ""Y8888b.
                                        "Y8P"               "Y8P'
                                            `.               ,'
                                              \     .-.     /
                                               \   (___)   /
    .------------------._______________________:__________j
    /                   |                      |           |`-.,_
    \###################|######################|###########|,-'`
    `------------------'                       :    ___   l
                                               /   (   )  \
                                              /     `-'     \
                                            ,'               `.
                                        .d8b.               .d8b.
                                        "Y8888p..       ,.d8888P"
                                            "Y88888888888888888P"
                                               ""YY8888888PP""
    --------------------------------------------------------------------------
    SCRIPT DESCRIPTION:
    
    This script can be used after running the random data generator script to randomly delete (or axe) a specific percentage of the generated folders.

    WARNING: This script has the potential to delete many folders very quickly. 
    Be very sure of the path and percentage you wish to delete before running this script. 
    Always run on a small, controlled set of data first to ensure it behaves as you expect.

    This PowerShell script performs the following actions:

    1. Defines a location containing a number of folders (modify the path to your needs).
    2. Sets a percentage of these folders to be deleted (the percentage is easily adjustable).
    3. Gets the current date and time (this is used later to calculate the total duration of the script).
    4. Retrieves a list of all folders in the defined location.
    5. Calculates the total number of folders, as well as the number of folders to be deleted based on the specified percentage.
    6. Randomly selects the folders to be deleted.
    7. Asks for user confirmation before proceeding with the deletion.
    8. If confirmed, each selected folder is deleted. If not, the script is terminated.
    9. The script records the end time, calculates the total duration, and displays a completion message.

#>


# Define the path to the location where folders are stored
$location = "f:\random"

# Define the percentage of folders to delete.
# This is expressed as a fraction of 1. For example, 1/100 = 1%,
# 20/100 = 20%, and 100/100 = 100% (i.e., all folders).
$percentageToDelete = 100 / 100  

# Record the start time of the script for later calculation of total duration
$StartTime = Get-Date

# Get a list of all folders in the specified location
$folders = Get-ChildItem -Path $location -Directory

# Calculate the total number of folders and the number to delete
$folderCount = $folders.Count
$folderCountToDelete = [Math]::Floor($folderCount * $percentageToDelete)

# Choose the folders to delete. This selection is random.
$foldersToDelete = Get-Random -InputObject $folders -Count $folderCountToDelete

# Display a message to the user indicating the number of folders about to be deleted
Write-Output "About to delete $folderCountToDelete folders. Do you want to proceed? (yes/no)"

# Get user confirmation before proceeding
$response = Read-Host
if ($response -eq 'yes') {
    # If the user confirms, delete each folder in the selected list
    foreach ($folder in $foldersToDelete) {
        Remove-Item -Path $folder.FullName -Recurse -Force
        Write-Output "Deleted folder: $($folder.FullName)"
    }
} else {
    # If the user does not confirm, display a message and stop execution
    Write-Output "Operation cancelled by user."
}

# Record the end time of the script
$EndTime = Get-Date

# Calculate the total duration of the script in minutes
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

# Display a completion message and the duration of the script
Write-Output "Deletion complete"
Write-Output "StartTime: $StartTime"
Write-Output "EndTime: $EndTime"
Write-Output "Duration: $duration minutes"
