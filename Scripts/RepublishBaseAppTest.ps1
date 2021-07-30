$ServerInstance = "BonavaTest"
$ApplicationPath = "C:\Users\ZEXT.rualepop\AL\N17Construction\AL\BaseApp\Microsoft_Base Application_17.4.21491.21539.app"

$quietExecution = $null

$quietExecution = ./Modules/NavAdminTool.ps1
$quietExecution = Import-Module ".\Modules\AppAdminToolTest.psm1"

RepublishBaseApp -ServerInstanceName $ServerInstance -ApplicationName "Base Application" -ApplicationPath $ApplicationPath

Write-Output "Base Application has been republished successfully."