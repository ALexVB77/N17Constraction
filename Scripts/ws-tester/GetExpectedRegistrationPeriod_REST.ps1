$XmlObjectsFolder = 'C:\Temp\CRM-UNIT-XML'
$JsonObjectsFolder = 'C:\Temp\JSON'
$ResultFileName = "C:\Temp\Result_GetExpectedRegistrationPeriod_REST.txt"

$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/ODataV4/Utils_GetExpectedRegistrationPeriodREST"
$ContentType = "application/json"

$Res = ""
$Files = Get-ChildItem -Path "$XmlObjectsFolder\*" -Include "*.xml"
if (!$Files){
   Write-Host "There are no xml files!"
} else {
   $Files | ForEach-Object {
      $Filename = Join-Path -Path $XmlObjectsFolder -ChildPath $_.Name
      $JsonFilename = Join-Path -Path $JsonObjectsFolder -ChildPath ($_.Name + ".json.txt")
      $XmlContent = Get-Content -Path $Filename -Encoding utf8
      $Base64XmlContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($XmlContent))
      $Body = @{ encodedObjectXml = $Base64XmlContent } | ConvertTo-Json
      $Response = Invoke-RestMethod -Method 'Post' -Uri $url -ContentType $ContentType -UseDefaultCredential -Body $Body
      $Tmp = $Response.value
      $Res = $Res + "$Tmp`r`n"
      Write-Host $Tmp
   }
}

Set-Content -Path $ResultFileName -Value $Res
