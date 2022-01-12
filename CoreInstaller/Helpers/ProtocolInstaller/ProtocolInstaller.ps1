function Add-CoreProtocol{
    $root = $RmAPI.VariableStr('ROOTCONFIGPATH') + 'CoreInstaller'
    Start-Process powershell -ArgumentList "`$ep = Get-ExecutionPolicy -Scope CurrentUser; Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; & `"$root\Helpers\CoreInstaller\CoreInstallerWebSupport.ps1`" `"$root\Helpers\CoreInstaller\CoreInstaller.exe`" `"$($RmAPI.VariableStr('@'))WebSupportEnabled.inc`"; Set-ExecutionPolicy `$ep -Scope CurrentUser -Force" -Verb RunAs
}
function Remove-Protocol {
    Start-Process powershell -ArgumentList "`$ep = Get-ExecutionPolicy -Scope CurrentUser; Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; & '$root\Helpers\CoreInstaller\CoreInstallerWebSupport.ps1' '' '$($RmAPI.VariableStr('@'))WebSupportEnabled.inc' 'T'; Set-ExecutionPolicy `$ep -Scope CurrentUser -Force" -Verb RunAs    
}