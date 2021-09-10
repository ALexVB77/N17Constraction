$Cred = Get-Credential
$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/api/bonava/crm/beta/companies(53e2e139-aabf-eb11-a6ad-00155d012301)/crmObjects"
$Body = @{
    name = "Contact 2"
    isActive = $true
    jsonArray = "val1", "val2"
} | ConvertTo-Json

$ContentType = "application/json"

Invoke-RestMethod -Method 'Post' -Uri $url -Credential $Cred -Body $Body -ContentType $ContentType
