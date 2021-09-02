#param($XmlObjectsFolder)

#$EndpointUrl = "https://vm-tst-app035.oneplatform.info:7147/BonavaTest/WS/Bonava/Codeunit/CrmAPI"
$EndpointUrl = "http://nav-bonava.ncdev.ru:17057/BonavaDev/WS/CRONUS%20%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D1%8F%20%D0%97%D0%90%D0%9E/Codeunit/crmTester"

$WS = New-WebServiceProxy $EndpointUrl -UseDefaultCredential
$WS.Timeout = [System.Int32]::MaxValue

$XmlObjectsFolder = 'C:\Temp\CRM1'

$SoapEnvelope = @"
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <soap:Body>
      _1_
   </soap:Body>
</soap:Envelope>
"@

$XmlObject = "<object>_1_</object>"

<#
# single file
$WS = New-WebServiceProxy $EndpointUrl -UseDefaultCredential
$WS.Timeout = [System.Int32]::MaxValue
$Filename1 = "C:\Temp\CRM1\{88DF9990-9AAE-4676-948F-FA1CF28DF4D9}.xml"
$XmlContent1 = Get-Content -Path $Filename1 -Encoding utf8
$Base64XmlContent1 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($XmlContent1))
$EncodedXml1 =  $XmlObject.Replace("_1_", $Base64XmlContent1)
$SoapEnv1 = $SoapEnv.Replace("_1_", $EncodedXml1)
$ResponseText = $WS.GetApartmentType($SoapEnv1)
Write-Host $ResponseText
Remove-Variable WS

$WS = New-WebServiceProxy $EndpointUrl -UseDefaultCredential
$WS.Timeout = [System.Int32]::MaxValue
$Filename = "C:\Temp\CRM1\{153352F0-B993-479F-B62A-6F2FD2F9CFB4}.xml"
$XmlContent = Get-Content -Path $Filename -Encoding utf8
$Base64XmlContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($XmlContent))
$EncodedXml =  $XmlObject.Replace("_1_", $Base64XmlContent)
$SoapEnv = $SoapEnv.Replace("_1_", $EncodedXml)
$ResponseText = $WS.GetApartmentType($SoapEnv)
Write-Host $ResponseText


#>


#batch
$Base64XmlContentPrev = ""
$ResponseTextAll = ""
$Files = Get-ChildItem -Path "$XmlObjectsFolder\*" -Include "*.xml"
if (!$Files){
   Write-Host "There are no xml files!"
} else {
   $Files | ForEach-Object {

      $WS = New-WebServiceProxy $EndpointUrl -UseDefaultCredential
      $Filename = Join-Path -Path $XmlObjectsFolder -ChildPath $_.Name
      $XmlContent = Get-Content -Path $Filename -Encoding utf8
      $Base64XmlContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($XmlContent))
      $EncodedXml =  $XmlObject.Replace("_1_", $Base64XmlContent)
      $SoapEnv = $SoapEnvelope.Replace("_1_", $EncodedXml)
      $ResponseText = $WS.GetApartmentType($SoapEnv)
      if ($ResponseText -ne "-") {
         $ResponseTextAll = $ResponseTextAll + "$ResponseText`r`n"
      }
      $Base64XmlContentPrev = $Base64XmlContent

   }
}

$LogFilePath = "C:\Temp\crm1.txt"
Set-Content -Path $LogFilePath  -Value $ResponseTextAll
Write-Host "Result was save into $LogFilePath"
