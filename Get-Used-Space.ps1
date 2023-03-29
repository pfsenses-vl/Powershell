#Get Used Space for All hosts in selected OU
Import-Module ActiveDirectory
$Winservers=(Get-ADComputer -Filter *  -searchbase "OU=Servers,DC=EXAMPLE,DC=ORG" -SearchScope 2).Name
$Total=foreach ($item in $Winservers){Invoke-Command -ComputerName $item {Get-PSDrive -PSProvider FileSystem} | Select-Object PSComputerName,Name,@{Name="UsedSpace";Expression={$_.Used/1GB}}}
if (!(Test-Path -Path C:\Scripts\CSV)){New-Item -ItemType Directory -Path C:\Scripts\CSV | Out-Null}
$Total | Where-Object UsedSpace -ne "0" | Export-CSV C:\Scripts\CSV\FreeSpace.csv