#$Cred = Get-Credential
$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/ODataV4/Utils_Ping"
#$Url = "https://vm-tst-app035.oneplatform.info:7148/BonavaTest/api/bc/crm/beta/companies(53e2e139-aabf-eb11-a6ad-00155d012301)/units"
$JsonFile = ".\rest_json_samples\unit.json"
$Body = Get-Content -Path $JsonFile -Encoding utf8

$ContentType = "application/json"

#Invoke-RestMethod -Method 'Post' -Uri $url -Credential $Cred -Body $Body -ContentType $ContentType
#Invoke-RestMethod -Method 'Post' -Uri $url -Body $Body -ContentType $ContentType -UseDefaultCredential
Invoke-RestMethod -Method 'Post' -Uri $url  -ContentType $ContentType -UseDefaultCredential
