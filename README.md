# iis-app-pool-recycle
Powershell script for application pool recycle

.SYNOPSIS
Recycles a selected IIS application pool 

.DESCRIPTION
Recycle-AppPools.ps1 uses a PS session to connect to a local or remote computer. 
It pulls down the currently configured application pools and builds a menu. 
The end user gets to select from the menu which application pool to restart. 
The Recycle-AppPools.ps1 then connects back to the PS Session and recycles the selected application pool.

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
