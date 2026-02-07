$data = @()

$body = @{
username = “"
password = “”
}

$hostName = $env:COMPUTERNAME
$path = "C:\Backups\Appvolumes"
if (!(Test-Path $path))
{
    New-Item -Path "C:\Backups\Appvolumes" -ItemType "directory"
}

Invoke-RestMethod "https:///cv_api/sessions" -Method Post -SessionVariable Apilogin -Body $body

$appStacks = Invoke-RestMethod "https:///cv_api/appstacks" -Method Get -WebSession $Apilogin

for ($i = 0; $i -lt $appStacks.count; $i++)
{
    $appstack = $appStacks.Item($i)

    $row = New-Object PSObject
    $row | Add-Member -MemberType NoteProperty -Name "id" -Value $appstack.id
    $row | Add-Member -MemberType NoteProperty -Name "name" -Value $appstack.name
    $row | Add-Member -MemberType NoteProperty -Name "path" -Value $appstack.path
    $row | Add-Member -MemberType NoteProperty -Name "status" -Value $appstack.status
    $row | Add-Member -MemberType NoteProperty -Name "size" -Value $appstack.size_mb
    $row | Add-Member -MemberType NoteProperty -Name "host_name" -Value $hostName
    $data += $row

}

$data | Export-Csv ("C:\Backups\Appvolumes\Appstacks-" + (Get-Date -format "dd-MM-yyyy") + ".csv")

