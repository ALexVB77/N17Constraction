$XmlObjectsFolder = 'C:\Temp\XML'
$JsonObjectsFolder = 'C:\Temp\JSON'

$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/ODataV4/Utils_ConvertObjectXmlToJson"
$ContentType = "application/json"

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
      $JsonText = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Response.value))
      Set-Content -Path $JsonFilename -Value $JsonText
   }
}
