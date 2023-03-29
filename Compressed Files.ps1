############################################################################################################
# Warning!! Script not optimized for file servers with millions of files.
############################################################################################################

$Hostname = Read-Host "Please write target host"
$Target = "target.example.com"
function Get-Compressed-Files {
$DriveLetter=([System.IO.DriveInfo]::getdrives() | Where-Object {$_.DriveType -eq 'Fixed'}).Name
$Folders=foreach ($item in $DriveLetter){Get-ChildItem -Path $DriveLetter}
$folders=$folders | Where-Object Name -ne "PerfLogs"
$folders=$folders | Where-Object Name -ne "Program Files"
$folders=$folders | Where-Object Name -ne "Program Files (x86)"
$folders=$folders | Where-Object Name -ne "Windows"
$folders=$folders | Where-Object Name -ne "Users"
$Folders=$Folders.FullName

$files=foreach ($item in $Folders){Get-ChildItem -Path $item -Recurse}
$Files=$Files.FullName
if (!(Test-Path -Path C:\Scripts\Reports\NTFS)){New-Item -ItemType Directory -Path C:\Scripts\Reports\NTFS | Out-Null}
$Compressed = Foreach ($item in $Files){((Get-ItemProperty -Path \\?\$item | Where-Object {$_.Attributes -eq "Archive, Compressed" -or $_.Attributes -eq "Compressed"}).FullName)}
$Compressed | Out-File C:\Scripts\Reports\NTFS\$env:computername.txt}

Invoke-Command -ComputerName $Hostname -Credential $Credentials -ScriptBlock ${Function:\Get-Compressed-Files}
Robocopy.exe \\$Hostname\C$\Scripts\Reports\NTFS\ \\$Target\C$\Scripts\Reports\NTFS\ /MIR > $null