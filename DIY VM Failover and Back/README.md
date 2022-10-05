# Pure Storage Flash Array ActiveDR DIY VM Failover and Back scripts
Used in conjunction with ActiveDR to Failover VMs from one DC to Another


## Requirements
### These Powershell scripts depend upon:
VMware PowerCLI
```pwsh
Get-Module -Name VMware.PowerCLI -ListAvailable
```
Pure Storage PowerShell SDK - v1 and v2
```pwsh
Get-Module -ListAvailable -Name "PureStoragePowerShellSDK"
Get-Module -ListAvailable -Name "PureStoragePowerShellSDK2"
```
Pure Storage FlashArray Module for VMware
```pwsh
Get-Module -ListAvailable -Name "PureStorage.FlashArray.VMware"
```

## Pre-Requisites
### Variables
Update the ``.ps1`` files with the your variable information
```pwsh
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
  ```
### facred.xml
This is the connection credential. Write to file using ``"Get-Credential | Export-CliXml c:\PS\cred.xml"``
- Username and Password must work across the fleet or arrays

Alternately you could use something like

``$fa = New-PfaConnection -endpoint $array -credentials (get-credential) -IgnoreCertificateError``
