# Pure Storage Flash Array vVol Dev Copy scripts
Used to create a copy of a vVol volume from a Source "PROD" VM to a Target "DEV" VM

Then used to refresh those vVol volumes


## Requirements
### These Powershell scripts depend upon:
VMware PowerCLI
```pwsh
Get-Module -Name VMware.PowerCLI -ListAvailable
```
Pure Storage PowerShell SDK (v1)
```pwsh
Get-Module -ListAvailable -Name "PureStoragePowerShellSDK"
```
Pure Storage FlashArray Module for VMware
```pwsh
Get-Module -ListAvailable -Name "PureStorage.FlashArray.VMware"
```

## Pre-Requisites
### Variables
Update the ``.ps1`` files with the your variable information
```pwsh
$array = "ARRAY.DOMAIN.int"
$facred = Import-CliXml ./facred.xml
$vcs = "VC1.DOMAIN.int", "VC2.DOMAIN.int"
$vcenteruser = “user@.DOMAIN.int“
$vcenterpw = “PASSWORD“
#VMs in scope
$prodvm = "prod-vvol-vm01"
$devvm1 = "dev-vvol-vm01"
$devvm2 = "dev-vvol-vm02"
$devvm3 = "dev-vvol-vm03"
$uatvm1 = "uat-vvol-vm01"
  ```
### facred.xml
This is the connection credential. Write to file using ``"Get-Credential | Export-CliXml c:\PS\cred.xml"``
Username and Password must work across the fleet or arrays

Alternately you could use something like
``$fa = New-PfaConnection -endpoint $array -credentials (get-credential) -IgnoreCertificateError``