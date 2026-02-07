$body = @{
username = “"
password = “”
}

$hostName = $env:COMPUTERNAME
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$path = ("C:\Backups\Appvolumes\Applications\Backup-" + $timestamp)
if (!(Test-Path $path))
{
    New-Item -Path "C:\Backups\Appvolumes\Applications" -Name ("Backup-" + $timestamp) -ItemType "directory"
}

Invoke-RestMethod "https:///cv_api/sessions" -Method Post -SessionVariable Apilogin -Body $body

$appStacks = Invoke-RestMethod "https:///cv_api/appstacks" -Method Get -WebSession $Apilogin

for ($i = 0; $i -lt $appStacks.count; $i++)
{

    $data = @()

    $appstack = $appStacks.Item($i)
    $applications = Invoke-RestMethod ("https:///cv_api/appstacks/" + $appstack.id + "/applications") -Method Get -WebSession $Apilogin
    
    write-host "working on: " $appstack.name

    for ($b = 0; $b -lt $applications.applications.Count; $b++)
    {
        $application = $applications.applications.Item($b)

        $row = New-Object PSObject
        $row | Add-Member -MemberType NoteProperty -Name "id" -Value $application.id
        $row | Add-Member -MemberType NoteProperty -Name "name" -Value $application.name
        $row | Add-Member -MemberType NoteProperty -Name "icon" -Value $application.icon
        $row | Add-Member -MemberType NoteProperty -Name "version" -Value $application.version
        $row | Add-Member -MemberType NoteProperty -Name "publisher" -Value $application.publisher
        $row | Add-Member -MemberType NoteProperty -Name "host_name" -Value $hostName
        $data += $row

    }

    $path = "C:\Backups\Appvolumes\Applications\" + ("Backup-" + $timestamp) + "\" + ($appstack.name.Replace("/","-")) + ".csv"
    $data | Export-CSV $path
}

