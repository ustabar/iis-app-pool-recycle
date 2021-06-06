<#
.SYNOPSIS
Recycles a selected IIS application pool 

.DESCRIPTION
Recycle-AppPools.ps1 uses a PS session to connect to a local or remote computer. It pulls down the currently configured application pools and builds a menu. 
The end user gets to select from the menu which application pool to restart. The Recycle-AppPools.ps1 then connects back to the PS Session and recycles the selected
application pool.

.PARAMETER ServerNAme 
a single computer name or leave off for localhost

.PARAMETER WithCredentials
Use this switch to specifiy credentials other than the current logged in user.

.EXAMPLE
Recycle-AppPool.ps1 -ServerName REMOTESERVER
Will run on a remote server with current logged in creds

.EXAMPLE 
Recycle-AppPool.ps1 -ServerName REMOTESERVER -WithCredentials
Will run on a server remotely with different credentials specified during launch

.EXAMPLE
Recycle-AppPool.ps1
Will run on locally. Defaults to localhost with current logged in user

.NOTES
WithCredentials is a switch, it does not accept any credentials. A prompt will appear later.
#>

Param(
   [string]$ServerName = 'localhost',
   [switch]$WithCredentials
 
) #end param
 
# if (!(Test-Connection -ComputerName $ServerName -Quiet -Count 1))
# {
#     Write-Output "Unable to connect to $serverName"
#     break
# }
 
$scriptBlock = {
    Clear-Host
    Write-Output "Connected to: $env:computerName"
    if (Get-Module -ListAvailable -Name WebAdministration)
    {
        Write-Host "Loading PowerShell Web Administration..."
        Import-Module WebAdministration -ErrorAction SilentlyContinue
    }
    else
    {
        Write-Host "WebAdministration module does not exist..."
        break
    }
 
    $poolTable = @{}
    $allAppPools = Get-ChildItem IIS:\apppools
    $poolNumber = 0 
    Write-Output "Select Application Pool to Restart on server: $env:computerName"
    Write-Output ""
    foreach ($appPool in $allAppPools )
    {
        $pool = $appPool.Name
        $poolNumber += 1
        $poolTable.Add($poolNumber, $pool)
        Write-Output "$poolNumber > To restart app pool : $pool "
    }
    Write-Output ""
    $selectedPool = Read-Host "Enter # of Application Pool to Restart "
    if ($selectedPool)
    {    
        foreach ($hashValue in $poolTable.GetEnumerator())
        {  
            $key = $hashValue.Name
            $val = $hashValue.Value 
            if ($key -eq $selectedPool)
            {
                Write-Output "Restarting : $val"          
                Restart-WebAppPool $val       
            } 
        }
    }
    Write-Output "Completed reset on: $env:computerName"
    Write-Output ""
}
 
try {
     
    if ($WithCredentials)
    {
        $credentials = Get-Credential -Message "Enter credentials with administrative privilege on server"
        $session = New-PSSession -ComputerName $serverName -Credential $credentials -ErrorAction SilentlyContinue
    }
    else
    {
        $session = New-PSSession -ComputerName $serverName -ErrorAction SilentlyContinue
    }
 
    if ($session)
    {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock -ErrorAction Continue
        Remove-PSSession -Session $session | Out-Null
    }
    else
    {
        Write-Output "An error has occured setting up PowerShell session (check username and password)"
    }
}
catch
{
    if ($session)
    {
        Remove-PSSession -Session $session | Out-Null
    }
    Write-Output "An error has occured setting up PowerShell session on $serverName "
}