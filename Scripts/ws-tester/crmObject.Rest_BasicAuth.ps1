<#
$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/api/bonava/crm/beta/companies(53e2e139-aabf-eb11-a6ad-00155d012301)/crmObjects"
$Body = @{
    name = "Contact 2"
    isActive = $true
    jsonArray = "val1", "val2"
} | ConvertTo-Json

$auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("navicons\rkharitonov:d42bKaHy"))
$headers = @{
    'userId' = 'UserIDValue'
    'token' = 'TokenValue'
    'contentType' = 'application/json'
    'authorization' = "NTLM $auth"
}


Invoke-RestMethod -Method 'Post' -Uri $url -Headers $headers -Body $Body

#>


$Url = "http://nav-bonava.ncdev.ru:17058/BonavaDev/api/beta/companies"
$headers = @{
    'contentType' = 'application/json'
    'authorization' = "Basic rkharitonov:d42bKaHy"
}


Invoke-RestMethod -Method 'Get' -Uri $url -Headers $headers
