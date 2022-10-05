#DIY SRM Process - Failover

$vcs = @(
"vc01.DOMAIN.int"
"vc02.DOMAIN.int"
# ... 
)
$vcuser         = "user@DOMAIN.int"
$vcpass         = "PASSWORD"
$prodcluster    = "PROD"
$drcluster      = "DR"
$PRODVMFolder   = "TEST-DIY-ActiveDR-PROD"
$DRVMFolder     = "TEST-DIY-ActiveDR-PROD"
$datastores = @(
"TEST-DIY-ActiveDR"
#...
)
$vms = @(
"TEST-DIY-MYSQL-01"
# ... 
)
$facred = Import-CliXml ./facred.xml
$faprod = "ARRAY1.DOMAIN.int"
$fadr = "ARRAY2.DOMAIN.int"


$prodpod    = "TEST-DIY-ActiveDR-PROD"
$prodhg     = "PROD-Cluster"
$drpod      = "TEST-DIY-ActiveDR-DR"
$drhg       = "DR-Cluster"


##########################################
#DIY SRM Process - Failover
#Log into each vCetner Server 
Foreach ($vc in $vcs) {
    Write-Host "logging into $vc"
    #try { $vCenter = Connect-VIServer -Server $vc -Credential $vccred}
    try { $vCenter = Connect-VIServer -Server $vc -User $vcuser -Password $vcpass}
    catch { echo "Error accessing $vc : $_" }
}

import-module -Name PureStoragePowerShellSDK2
#Log into PROD Falsh Array
Write-Host "logging into Flash Array $faprod"
$FlashArrayPROD = Connect-Pfa2Array -EndPoint $faprod -Credential $facred -IgnoreCertificateError -ErrorAction Stop

#Log into DR Falsh Array
Write-Host "logging into Flash Array $fadr"
$FlashArrayDR = Connect-Pfa2Array -EndPoint $fadr -Credential $facred -IgnoreCertificateError -ErrorAction Stop

#Shutdown VMs -PROD
try{
    foreach ($vmName in $vms) {
        $vm = Get-VM -Name $vmName -ErrorAction Stop
        switch($vm.PowerState){
        'poweredon' {
        Shutdown-VMGuest -VM $vm -Confirm:$false
        while($vm.PowerState -eq 'PoweredOn'){
        sleep 5
        $vm = Get-VM -Name $vmName
        }
   }
   Default {
        Write-Host "VM '$($vmName)' is not powered on!"
        }
   }
   Write-Host "$($vmName) has shutdown. Ready for removal."
}
}
Catch{
   Write-Host "VM '$($vmName)' not found!"
}

#remove VMs from Inventory - PROD
foreach ($vm in $vms) { 
    Write-Host "removing $vm from $PRODcluster"
    try { remove-vm $vm -Confirm:$false }
    catch { echo "Error removing $vm : $_" }
}


#unmount DS - PROD
# foreach ($ds in $datastores) { 
#     Write-Host "unmounting $ds from $prodcluster"
#     try { Get-Datastore $datastores | Unmount-Datastore }
#     catch { echo "Error Unmounting $ds : $_" }
#     Write-Host "detaching $ds from $prodcluster"
#     try { Get-Datastore $datastores | Detach-Datastore }
#     catch { echo "Error Detaching $ds : $_" }
# }

foreach ($ds in $datastores) {
    $uArgs = @{
        volumelabel = $ds
        nopersist = $true
    }
    Write-Host "unmounting $ds from $prodcluster"
    Get-Cluster $prodcluster| Get-VMHost -Datastore $ds | %{
        $esxcli = Get-EsxCli -VMHost $_ -V2
        $esxcli.storage.filesystem.unmount.Invoke($uArgs)
    }
}

foreach ($ds in $datastores) { 
    Write-Host "removing HostGroup from Flash Array Volume $ds"
    $prodvolumename = "$prodpod::$ds"
    Remove-Pfa2Connection -Array $FlashArrayPROD -HostGroupNames $prodhg -VolumeNames $prodvolumename
    
}

#### Really slow!


Write-Host "detaching $ds from $prodcluster"
Get-Cluster $prodcluster | Get-VMHost | Get-VMHostStorage -RescanAllHba -RescanVmfs




#Demote PROD POD - w/ Quiesce (Quiesce a source pod to ensure that all local data is replicated to the target pod before this pod is demoted)
Write-Host "Demote $prodpod POD with Quiesce"
Update-Pfa2Pod -Array $FlashArrayPROD -Name $prodpod -RequestedPromotionState "demoted" -Quiesce $true
do {
    Write-Host "Waiting for $prodpod POD to Quiesce and Demote"
    Start-Sleep -Milliseconds 500
    $prodpodstatus = Get-Pfa2Pod -Array $FlashArrayPROD -name $prodpod
} while ($prodpodstatus | select-string -pattern "demoting")

# Promote the DR Site Pod
Write-Host "Promote $drpod POD"
Update-Pfa2Pod -Array $FlashArrayDR -Name $drpod -RequestedPromotionState "promoted"
do {
    Write-Host "Waiting for Pod Promotion"
    Start-Sleep -Milliseconds 500
    $drpodstatus = Get-Pfa2Pod -Array $FlashArrayDR -name $drpod
} while ($drpodstatus | select-string -pattern "promoting")



#Connect to DR HG - note LUN-ID
foreach ($ds in $datastores) { 
    Write-Host "Add HostGroup from Flash Array Volume $ds"
    $drvolumename = "$drpod::$ds"
    New-Pfa2Connection -Array $FlashArrayDR -HostGroupNames $drhg -VolumeNames $drvolumename
}






#New Datastore - VMFS, DS NAMGet-Pfa2PodE, LUN-ID, Host, ##New SIG or ##existing, VMFS6
Write-Host "Scanning HBAs and VMFS on $drcluster Cluster hosts"
Get-Cluster $drcluster | Get-VMHost | Get-VMHostStorage -RescanAllHba -RescanVmfs


###### From jase
# Put all datastores attached to the host in an array variable
$DRVMHost = Get-Cluster -Name $drcluster | Get-VMhost | Select-Object -First 1
$PreFailOverDatastrores = $DRVMhost | Get-Datastore




#$VMHost = Get-Cluster $drcluster | Get-VMhost | Select-Object -First 1

$EsxCli = Get-EsxCli -VMHost $DRVMhost -V2

$Snaps = $esxcli.storage.vmfs.snapshot.list.invoke()
#$Snaps = $esxcli.storage.vmfs.snapshot.list($ds)

if ($Snaps.Count -gt 0) {
    Foreach ($Snap in $Snaps) {
        Write-Host "Snapshot Found: $($Snap.VolumeName)"
        $esxcli.storage.vmfs.snapshot.resignature.invoke(@{volumelabel=$($Snap.VolumeName)})
    }
} else {
    Write-Host "No Snapshot volumes found"
}

###### From jase
# Rescan the HBAs to ensure that the datastore is visible and may be used
Get-VMHostStorage -RescanAllHba -RescanVmfs -VMHost $DRVMhost | Out-Null
Get-Cluster $drcluster | Get-VMHost | Get-VMHostStorage -RescanAllHba -RescanVmfs  | Out-Null



# Pause for a few seconds
Start-Sleep -Seconds 5

# Get a list of all of the datastores on the host (including the new snapped datastore)
$PostFailOverDatastores = $DRVMhost | Get-Datastore


# Compare the pre/post datastore array variables to gather the name of the newly added datastore
# This datastore will have a name like snap-32a052-old-volume-name
$FailOverDatastores = (Compare-Object -ReferenceObject $PreFailOverDatastrores -DifferenceObject $PostFailOverDatastores).InputObject
Write-Host $FailOverDatastores



#Rename the Datastore
Get-Datastore -Name $FailOverDatastores | Set-Datastore -Name $datastores[0]

#17/08/22 - testing indicates not required
#Register VM - browse datastore, folder, find vmx, import to folder, Cluster, 
#$Datastore = Get-Datastore -Name $FailOverDatastores
#$VMFolder  = Get-Folder -Type VM -Name $DRVMFolder



foreach($datastore in $datastores) {
    # Searches for .VMX Files in datastore variable
    $ds = Get-Datastore -Name $Datastore | %{Get-View $_.Id}
    $SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
    $SearchSpec.matchpattern = "*.vmx"
    $dsBrowser = Get-View $ds.browser
    $DatastorePath = "[" + $ds.Summary.Name + "]"
     
    # Find all .VMX file paths in Datastore variable and filters out .snapshot
    $SearchResults = $dsBrowser.SearchDatastoreSubFolders($DatastorePath,$SearchSpec) | Where-Object {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + $_.File.Path} 

    # Register all .VMX files with vCenter
    foreach($SearchResult in $SearchResults) {
    New-VM -VMFilePath $SearchResult -VMHost $DRVMHost -Location $DRVMFolder -RunAsync -ErrorAction SilentlyContinue
   }
}



#Power on VM
# foreach ($vm in $vms) { 
#     Write-Host "powering on $vm from $drcluster" 
#     try { Start-VM $vm -Confirm:$false }
#     catch { echo "Error shutting down $vm : $_" }
# }

#Power on VM
foreach ($vm in $vms) { 
    Write-Host "powering on $vm from $drcluster" 
    try {
        try { Start-VM -VM $vm -ErrorAction Stop -ErrorVariable custErr }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            throw $_.Exception
        }
    }
    catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.VMBlockedByQuestionException] {
        Write-Output "Power on operation triggered a VMBlockedByQuestionException. Answering question with `"I moved it`"."
        Get-VMQuestion -VM $vm | Set-VMQuestion –Option "button.uuid.movedTheVM" -Confirm:$false   
    }
}


















