
param( 
  [String]$filepaths,
  [String]$message="No description provided... ",
  [String]$repo="adobe/UST-Install-Scripts"
  )

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$token = $env:GITHUB_TOKEN

$releaseURL = "https://api.github.com/repos/$repo/releases?access_token=$token"

$ctag = (Invoke-RestMethod -Uri $releaseURL -Method 'Get')[0].tag_name
$prefix = $ctag.Substring(0,$ctag.LastIndexOf(".") + 1)
$version = [int] $ctag.Substring($ctag.LastIndexOf(".")+ 1) + 1

$message = [System.Web.HttpUtility]::UrlDecode($message)
$message = $message.Replace("`"","'")
$message = $message.Replace("\","")
$message = $message.Replace("# ","")
$message = $message.Replace("`r`n","<br/>")
$message = $message.Replace("`n","<br/>")
$message = $message.Trim()

$body = '{' +
    '"tag_name": "' + $prefix + $version + '",' +
    '"target_commitish": "master",' +
    '"name": "' + $prefix + $version + '",' +
    '"body": "- ' + $message + '",' +
    '"draft": true,' +
    '"prerelease": false' +
'}'

Write-Host "Message: " + $message

$release = (Invoke-RestMethod -Uri $releaseURL -Method 'Post' -Body $body -Headers @{"Content-Type" = "application/json"})

foreach ($filepath in $filepaths.Split(",")) {

    $filepath = (Resolve-Path $filepath).path
    $filename = $filepath.Split("\")[-1]
    
    $uploadURL = "https://uploads.github.com/repos/$repo/releases/" + $release.id + "/assets?name=$filename&access_token=$token"
    Invoke-RestMethod -Uri $uploadURL -Method 'Post' -InFile $filepath -Headers @{"Content-Type" = "application/octet-stream"}

}



