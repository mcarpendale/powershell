#Define Variables
$array = "ARRAY.DOMAIN.int"
$facred = Import-CliXml ./facred.xml # This is the connection credential. Write to file using "Get-Credential | Export-CliXml c:\PS\cred.xml". Username and Password must work across the fleet or arrays
$vcs = "VC1.DOMAIN.int", "VC2.DOMAIN.int"
$vcenteruser = “user@.DOMAIN.int“
$vcenterpw = “PASSWORD“
#VMs in scope
$prodvm = "prod-vvol-vm01"
$devvm1 = "dev-vvol-vm01"
$devvm2 = "dev-vvol-vm02"
$devvm3 = "dev-vvol-vm03"
$uatvm1 = "uat-vvol-vm01"


#Log into each vCetner Server 
Foreach ($vc in $vcs) {
    Write-Host "logging into $vc"
    try { $vCenter = Connect-VIServer -Server $vc -User $vcenteruser -Password $vcenterpw}
    catch { echo "Error accessing $vc : $_" }
}

#Log into each Falsh Array
Write-Host "logging into $array"
$fa = New-PfaConnection -endpoint $array -credentials $facred -IgnoreCertificateError -DefaultArray


# Get Disk info for VMs in scope
Write-Host "Getting vVol disk info for $prodvm"
$disksProd = get-vm $prodvm | get-harddisk
Write-Host "Getting vVol disk info for $devvm1"
$disksDev1 = get-vm $devvm1 | get-harddisk
Write-Host "Getting vVol disk info for $devvm2"
$disksDev2 = get-vm $devvm2 | get-harddisk
Write-Host "Getting vVol disk info for $devvm3"
$disksDev3 = get-vm $devvm3 | get-harddisk
Write-Host "Getting vVol disk info for $uatvm1"
$disksUat1 = get-vm $uatvm1 | get-harddisk



Write-Host "Create New disk 1 from $prodvm to $devvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[1] -TargetVm (get-vm $devvm1)
Write-Host "Create New disk 2 from $prodvm to $devvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[2] -TargetVm (get-vm $devvm1)
Write-Host "Create New disk 3 from $prodvm to $devvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[3] -TargetVm (get-vm $devvm1)

Write-Host "Create New disk 1 from $prodvm to $devvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[1] -TargetVm (get-vm $devvm2)
Write-Host "Create New disk 2 from $prodvm to $devvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[2] -TargetVm (get-vm $devvm2)
Write-Host "Create New disk 3 from $prodvm to $devvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[3] -TargetVm (get-vm $devvm2)

Write-Host "Create New disk 1 from $prodvm to $uatvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[1] -TargetVm (get-vm $uatvm1)
Write-Host "Create New disk 2 from $prodvm to $uatvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[2] -TargetVm (get-vm $uatvm1)
Write-Host "Create New disk 3 from $prodvm to $uatvm1"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[3] -TargetVm (get-vm $uatvm1)

Write-Host "Create New disk 1 from $prodvm to $uatvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[1] -TargetVm (get-vm $uatvm2)
Write-Host "Create New disk 2 from $prodvm to $uatvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[2] -TargetVm (get-vm $uatvm2)
Write-Host "Create New disk 3 from $prodvm to $uatvm2"
Copy-PfaVvolVmdkToNewVvolVmdk -vmdk $disksProd[3] -TargetVm (get-vm $uatvm2)





$disksProd = get-vm prod-vvol-vm01 | get-harddisk 
$disksDev = get-vm dev-vvol-vm01 | get-harddisk 
$mikevm = 'mc-vvol-test'
$disksmike = get-vm mc-vvol-test |Get-HardDisk

Copy-PfaVvolVmdkToExistingVvolVmdk -sourceVmdk $disksProd[1] -targetVmdk $disksDev[1]
Copy-PfaVvolVmdkToExistingVvolVmdk -sourceVmdk $disksProd[2] -targetVmdk $disksDev[2]




Install-Module -Name PureStoragePowerShellSDK