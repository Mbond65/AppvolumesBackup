$body = @{
username = “"
password = “”
}

$path = ("C:\Backups\Appvolumes\Assignments\Backup-" + (Get-Date -format "dd-MM-yyyy"))
if (!(Test-Path $path))
{
    New-Item -Path "C:\Backups\Appvolumes\Assignments" -Name ("Backup-" + (Get-Date -format "dd-MM-yyyy")) -ItemType "directory"
}

Invoke-RestMethod "https:///cv_api/sessions" -Method Post -SessionVariable Apilogin -Body $body

$appStacks = Invoke-RestMethod "https:///cv_api/appstacks" -Method Get -WebSession $Apilogin

for ($i = 0; $i -lt $appStacks.count; $i++)
{

    $data = @()

    $appstack = $appStacks.Item($i)
    $assignments = Invoke-RestMethod ("https://cv_api/appstacks/" + $appstack.id + "/assignments") -Method Get -WebSession $Apilogin   

    for ($b = 0; $b -lt $assignments.Count; $b++)
    {
        $assignment = $assignments.Item($b)

        $row = New-Object PSObject
        $row | Add-Member -MemberType NoteProperty -Name "name" -Value $assignment.name
        $data += $row

    }

    $path = "C:\Backups\Appvolumes\Assignments\" + ("Backup-" + (Get-Date -format "dd-MM-yyyy")) + "\" + ($appstack.name.Replace("/","-")) + ".csv"
    $data | Export-CSV $path
}

