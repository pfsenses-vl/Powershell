###########################################################################################################
#This script collecting information about NTLM Auth from Domain Controllers Eventlog, and export it to CSV. 
###########################################################################################################
Import-Module ActiveDirectory
$Domain = Get-ADDomain | Select DNSRoot, distinguishedName
$Account = Get-ADUser ($env:UserName) |select SamAccountName
$adminsuffix = "ad-"
$DomainAccount = $Domain.DNSRoot + "\" +$adminsuffix + $Account.SamAccountName.split("-")[1]
$Password =  Read-Host "Enter Administrator Password" -AsSecureString
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $DomainAccount, $Password
$DC=(Get-ADComputer -Filter 'Name -like "*DCName-Mask*"').Name
ForEach ($item in $DC){Invoke-Command -ComputerName "$item" {Get-WinEvent -LogName 'Security' -FilterXPath '*[System[EventID=4624]]' | select @{Label='Time';Expression={$_.TimeCreated.ToString('g')}},@{Label="Logon Type";Expression={switch (foreach {$_.properties[8].value}) {
0 {"System"; break;}
2 {"Interactive"; break;}
3 {"Network"; break;}
4 {"Batch"; break;}
5 {"Service"; break;}
6 {"Proxy"; break;}
7 {"Unlock"; break;}
8 {"NetworkCleartext"; break;}
9 {"NewCredentials"; break;}
10 {"RemoteInteractive"; break;}
11 {"CachedInteractive"; break;}
12 {"CachedRemoteInteractive"; break;}
13 {"CachedUnlock"; break;}
default {"Other"; break;}}}},@{Label='Authentication';Expression={$_.Properties[10].Value}},@{Label='User Name';Expression={$_.Properties[5].Value}},@{Label='Client Name';Expression={$_.Properties[11].Value}},@{Label='Client Address';Expression={$_.Properties[18].Value}},@{Label='Server Name';Expression={$_.MachineName}} | sort @{Expression="Server Name";Descending=$false},
@{Expression="Time";Descending=$true}} | Where-Object Authentication -eq "NTLM" |Select-Object * -ExcludeProperty PSComputerName, RunspaceID | Export-csv -Append C:\Scripts\CSV\NTLM.csv}