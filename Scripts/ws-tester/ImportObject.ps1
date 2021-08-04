$CrmWSUrlTest = "https://vm-tst-app035.oneplatform.info:7147/BonavaTest/WS/Bonava/Codeunit/CrmAPI"

$WS = New-WebServiceProxy $CrmWSUrlTest -UseDefaultCredential
$WS.Timeout = [System.Int32]::MaxValue

$XmlObjectsFolder = 'C:\Temp\CRM\xml'
$ScriptFolder = 'C:\Temp\CRM\'


$SoapEnv = @"
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <soap:Body>
      <crm_objects>
         _1_
      </crm_objects>
   </soap:Body>
</soap:Envelope>
"@

$XmlObject = "<object>_1_</object>"
$XmlAllObjects = ""

$XmlFilesMask = Join-Path -Path $XmlObjectsFolder -ChildPath "\*"
$Files = Get-ChildItem -Path $XmlFilesMask -Include "*.xml"
if (!$Files){
   Write-Host "There are no xml files!"
} else {
   $Files | ForEach-Object {
      $Filename = Join-Path -Path $XmlObjectsFolder -ChildPath $_.Name
      $XmlContent = Get-Content -Path $Filename -Encoding utf8
      $Base64XmlContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($XmlContent))
      $XmlAllObjects += $XmlObject.Replace("_1_", $Base64XmlContent)
   }
}

$SoapEnv = $SoapEnv.Replace("_1_", $XmlAllObjects)

#$DebugFile = Join-Path -Path $ScriptFolder -ChildPath "debug_request_body.xml"
#Set-Content -Path $DebugFile  -Value $SoapEnv

$ResponseText = $WS.ImportObject($SoapEnv)
Write-Host $ResponseText
pause

