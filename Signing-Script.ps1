#This script require Deployed CA Service,Alowed CA Template CodeSigning, and installed certificate, which will be used for signing:
$LocalCert=(Get-ChildItem -Path Cert:\CurrentUser\My).EnhancedKeyUsageList.FriendlyName 
if (!($LocalCert)) {Set-Location -Path cert:\CurrentUser\My | Out-Null;Get-Certificate -Template CodeSigning | Out-Null;Start-Sleep -Seconds 2}
$cert = (Get-ChildItem cert:\CurrentUser\my –CodeSigningCert)
Set-AuthenticodeSignature -Certificate $cert -FilePath 'C:\Scripts\Target Script.ps1' | Select-Object Path,StatusMessage,Status
