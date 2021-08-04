$CrmObjectsFolder = 'C:\Temp\CRM\xml'

$Files = Get-ChildItem -Path "$CrmObjectsFolder\*" -Include "*.xml"
if (!$Files){
   Write-Host "No files!"
} else {
   $Files | ForEach-Object {
      Write-Host $_.Name
      $Cont += $_.Name
   }
}
