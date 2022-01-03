$ErrorActionPreference = 'SilentlyContinue'

$skinsList = $RmAPI.VariableStr('SKINLIST') -split '\s*\|\s*'

#@('IdleStyle', 'Keystrokes', 'MIUI-Shade', 'ModularClocks', 'ModularPlayers', 'Plainext', 'QuickNote', 'ValliStart')

$api = "https://api.github.com/repos/Jax-Core/{skin}/releases/latest"

$root = $RmAPI.VariableStr("@") + "CoreInstaller"
$resources = $RmAPI.VariableStr('@')
$skinsPath = $RmAPI.VariableStr('SKINSPATH')
$helpersPath = $RmAPI.VariableStr('CURRENTPATH') + 'Helpers'

function Get-Skin {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $skin
    )

    if ($skin -match '#?JaxCore') {
        Update-Core
        return
    }

    if ($skinsList -notcontains $skin) {
        $RmAPI.LogError("CoreInstaller: Skin name `"$skin`" invalid (Error: 1)")
        return
    }

    $releaseInfo = (Invoke-WebRequest -Uri "$($api -replace '{skin}', $skin)" -UseBasicParsing -ErrorAction Stop).Content | ConvertFrom-Json

    $global:downloadUri = ''
    $releaseInfo.assets | ForEach-Object {
        if ($_.name -match ".zip$") {
            $global:downloadUri = $_.browser_download_url
        }
    }

    $RmApi.Bang("!SetClip $downloadUri")

    debug("Parsed download url: `"$downloadUri`"")
    
    New-Cache # reset the cache folder

    Get-Webfile $downloadUri "$root\cache\$skin.zip"

    debug("CoreInstaller: Successfully downloaded `"$skin.zip`"")

    $RmAPI.Bang("[!SetVariable Progress `"0`"][!SetVariable InstallText `"Extracting files`"][!UpdateMeterGroup Progress][!Redraw]")

    Expand-Archive -LiteralPath "$root\cache\$skin.zip" -DestinationPath "$root\cache\Raw$skin"

    [System.IO.Directory]::CreateDirectory("$root\cache\$skin")

    Copy-Item -LiteralPath "$root\cache\Raw$skin\#Installer\Plugins" -Destination "$root\cache\$skin\Plugins" -Force -Recurse
    Copy-Item -LiteralPath "$root\cache\Raw$skin\#Installer\VariableFiles.txt" -Destination "$root\cache\$skin\VariableFiles.txt" -Force

    Remove-Item -LiteralPath "$root\cache\Raw$skin\#Installer" -Force -Recurse

    Copy-Item -LiteralPath "$root\cache\Raw$skin" -Destination "$root\cache\$skin\Skins" -Force -Recurse

    Start-Sleep -Milliseconds 200
    # Move the skins

    Install-Variables -skin $skin

    $RmAPI.Bang("[!SetVariable Progress `"70`"][!SetVariable InstallText `"Installing skin`"][!UpdateMeterGroup Progress][!Redraw]")

    Remove-Item -LiteralPath "$skinsPath\$skin" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -LiteralPath "$root\cache\$skin\Skins" -Destination "$skinsPath$skin" -Recurse -Force

    Start-Sleep -Milliseconds 200

    $RmAPI.Bang("[!SetVariable Progress `"90`"][!SetVariable InstallText `"Installing plugins`"][!UpdateMeterGroup Progress][!Redraw]")

    $RmAPI.Bang("[!WriteKeyValue Rainmeter OnRefreshAction `"`"`"[!Hide][!CommandMeasure DelayedBanger `"finalize('$skin ')`"]`"`"`"]")

    $RmAPI.Bang('[!DeactivateConfig "#JaxCore\Main"]')

    Start-Sleep -Milliseconds 500

    $pluginsDir = "`"$root\cache\$skin\Plugins`""
    $rmPluginsDir = "`"$($RmAPI.VariableStr('SETTINGSPATH'))Plugins`""
    $rmPath = "`"$($RmAPI.VariableStr('PROGRAMPATH'))Rainmeter.exe`""
    $postBang = "`"[!Log Done]`""

    Start-Process "$helpersPath\PluginsInstaller\PluginsInstaller.exe" "--pluginsDir $pluginsDir --rmPluginsDir $rmPluginsDir --rmPath $rmPath --postBangs $postBang --bangDelay 500"
}
function Update-Core {
    $skin = 'JaxCore'

    $releaseInfo = (Invoke-WebRequest -Uri "$($api -replace '{skin}', $skin)" -UseBasicParsing -ErrorAction Stop).Content | ConvertFrom-Json

    $global:downloadUri = ''

    $releaseInfo.assets | ForEach-Object {
        if ($_.name -match ".zip$") {
            $global:downloadUri = $_.browser_download_url
        }
    }

    debug("Parsed download url: `"$downloadUri`"")
    
    New-Cache # reset the cache folder

    Get-Webfile $downloadUri "$root\cache\$skin.zip"

    debug("CoreInstaller: Successfully downloaded `"$skin.zip`"")

    $RmAPI.Bang("[!SetVariable Progress `"0`"][!SetVariable InstallText `"Removing old files`"][!UpdateMeterGroup Progress][!Redraw]")

    Copy-Item "$($RmAPI.VariableStr('SKINSPATH'))#JaxCore" "$root\cache\Old$skin" -Recurse -Force

    Get-ChildItem "$($RmAPI.VariableStr('ROOTCONFIGPATH'))" | ForEach-Object {
        if ($_.FullName -notmatch '@Resources') {
            Remove-Item $_.FullName -Force -Recurse
        }
    }

    Get-ChildItem "$($RmAPI.VariableStr('@'))" | ForEach-Object {
        if ($_.FullName -notmatch 'CoreInstaller') {
            Remove-Item $_.FullName -Force -Recurse
        }
    }

    $RmAPI.Bang("[!SetVariable Progress `"10`"][!SetVariable InstallText `"Extracting files`"][!UpdateMeterGroup Progress][!Redraw]")

    Expand-Archive -LiteralPath "$root\cache\$skin.zip" -DestinationPath "$root\cache\Raw$skin"

    [System.IO.Directory]::CreateDirectory("$root\cache\$skin")

    Copy-Item -LiteralPath "$root\cache\Raw$skin\#Installer\Plugins" -Destination "$root\cache\$skin\Plugins" -Force -Recurse
    Copy-Item -LiteralPath "$root\cache\Raw$skin\#Installer\VariableFiles.txt" -Destination "$root\cache\$skin\VariableFiles.txt" -Force

    Remove-Item -LiteralPath "$root\cache\Raw$skin\#Installer" -Force -Recurse
    # Remove-Item -LiteralPath "$root\cache\Raw$skin\CoreInstaller" -Force -Recurse
    Remove-Item -LiteralPath "$root\cache\Raw$skin\@Resources\CoreInstaller" -Force -Recurse

    Copy-Item -LiteralPath "$root\cache\Raw$skin" -Destination "$root\cache\$skin\Skins" -Force -Recurse

    Start-Sleep -Milliseconds 200
    # Move the skins

    Install-Variables -skin $skin

    $RmAPI.Bang("[!SetVariable Progress `"70`"][!SetVariable InstallText `"Installing skin`"][!UpdateMeterGroup Progress][!Redraw]")

    Copy-Item "$root\cache\$skin\Skins\*" "$skinsPath#$skin" -Force -Recurse

    Start-Sleep -Milliseconds 200

    $RmAPI.Bang("[!SetVariable Progress `"90`"][!SetVariable InstallText `"Installing plugins`"][!UpdateMeterGroup Progress][!Redraw]")

    $RmAPI.Bang("[!WriteKeyValue Rainmeter OnRefreshAction `"`"`"[!Hide][!CommandMeasure DelayedBanger `"finalize('JaxCore')`"]`"`"`"]")

    $RmAPI.Bang('[!DeactivateConfig "#JaxCore\Main"]')

    Start-Sleep -Milliseconds 500

    $pluginsDir = "`"$root\cache\$skin\Plugins`""
    $rmPluginsDir = "`"$($RmAPI.VariableStr('SETTINGSPATH'))Plugins`""
    $rmPath = "`"$($RmAPI.VariableStr('PROGRAMPATH'))Rainmeter.exe`""
    $postBang = "`"[!Log Done]`""

    Start-Process "$helpersPath\PluginsInstaller\PluginsInstaller.exe" "--pluginsDir $pluginsDir --rmPluginsDir $rmPluginsDir --rmPath $rmPath --postBangs $postBang --bangDelay 500"
}
function Exit-Installation {
    param(
        [Parameter()]
        [string]
        $skin
    )
    if ($skin -match 'JaxCore') {
        $RmAPI.Bang("[!WriteKeyValue Variables Sec.Page 1 `"$($RmAPI.VariableStr('ROOTCONFIGPATH'))Main\Home.ini`"][!ActivateConfig `"#JaxCore\Main`"]")
    }
    else {
        if ($RmAPI.Variable('RequiresActivation') -eq 1) {
            $RmAPI.Bang("[!ActivateConfig `"$skin\Main`"][!WriteKeyValue Variables RequiresActivation 0]")
        }
        $RmAPI.Bang("[!WriteKeyvalue Variables Skin.Name $skin `"$($resources)SecVar.inc`"][!WriteKeyvalue Variables Skin.Set_Page Info `"$($resources)SecVar.inc`"][!ActivateConfig `"#JaxCore\Main`" `"Settings.ini`"]")
    }
    New-Cache
    Start-Sleep -Milliseconds 200
    $RmAPI.Bang('[!WriteKeyValue Rainmeter OnRefreshAction """[!ZPos 2][!SetWindowPosition 50% 20 50% 0%][!CommandMeasure mActions "Execute 1"]"""]')
    $RmAPI.Bang("!DeactivateConfig")
}
function New-Cache {
    [System.IO.Directory]::CreateDirectory("$root\cache") | Out-Null
    Get-ChildItem "$root\cache" | ForEach-Object {
        Remove-Item $_.FullName -Force -Recurse
    }
}

function debug {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`" Debug]")
}
function warning {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`" Warning]")
}
function error {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`" Error]")
}
function notice {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`"]")
}

function Get-Webfile ($url, $dest) {
    debug "Downloading $url`n"
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(5000)
    $response = $request.GetResponse()
    $length = $response.get_ContentLength()
    $responseStream = $response.GetResponseStream()
    $destStream = New-Object -TypeName System.IO.FileStream -ArgumentList $dest, Create
    $buffer = New-Object byte[] 100KB
    $count = $responseStream.Read($buffer, 0, $buffer.length)
    $downloadedBytes = $count

    while ($count -gt 0) {
        $RmAPI.Bang("[!SetVariable Progress `"$([System.Math]::Round(($downloadedBytes / $length) * 100,0))`"][!SetVariable InstallText `"Downloading [#Progress]%`"][!UpdateMeterGroup Progress][!Redraw]")
        $destStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer, 0, $buffer.length)
        $downloadedBytes += $count
    }

    debug "`nDownload of `"$dest`" finished."
    $destStream.Flush()
    $destStream.Close()
    $destStream.Dispose()
    $responseStream.Dispose()
}

function Install-Variables {
    param(
        [Parameter()]
        $skin
    )

    function debug {
        param(
            [Parameter()]
            [string]
            $message
        )

        $RmAPI.Bang("[!Log `"`"`"" + $message + "`"`"`" Debug]")
    }

    function warning {
        param(
            [Parameter()]
            [string]
            $message
        )

        $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`" Warning]")
    }

    function rmerror {
        param(
            [Parameter()]
            [string]
            $message
        )

        $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`" Error]")
    }

    function notice {
        param(
            [Parameter()]
            [string]
            $message
        )

        $RmAPI.Bang("[!Log `"`"`"CoreInstaller: " + $message + "`"`"`"]")
    }

    function Get-IniContent ($filePath) {
        $ini = [ordered]@{}

        $notSectionCount = 0

        foreach ($line in [System.IO.File]::ReadLines($filePath)) {
            if ($line -match "^\s*\[(.+?)\]\s*$") {
                $section = $matches[1]
                if ($ini.Keys -notcontains $section) {
                    $ini.Add($section, [ordered]@{})
                }
                $notSectionCount = 0
            }
            elseif ($line -match "^\s*;.*$") {
                $ini[$section].Add(";NotSection" + $notSectionCount, $line)
                $notSectionCount++
            }
            elseif ($line -match "^\s*(.+?)\s*=\s*(.+?)$") {
                $key, $value = $matches[1..2]
                $ini[$section].Add($key, $value)
            }
            else {
                $ini[$section].Add(";NotSection" + $notSectionCount, $line)
                $notSectionCount++
            }
        }

        return $ini
    }

    function Set-IniContent($ini, $filePath) {
        $str = @()

        foreach ($section in $ini.GetEnumerator()) {
            $str += "[" + $section.Key + "]"
            foreach ($keyvaluepair in $section.Value.GetEnumerator()) {
                if ($keyvaluepair.Key -match "^;NotSection\d+$") {
                    $str += $keyvaluepair.Value
                }
                else {
                    $str += $keyvaluepair.Key + " = " + $keyvaluepair.Value
                }
            }
        }

        $finalStr = $str -join [System.Environment]::NewLine

        $finalStr | Out-File -filePath $filePath -Force -Encoding unicode
    }

    $skinsPath = $RmAPI.VariableStr('SKINSPATH')
    $root = $RmAPI.VariableStr("@") + "CoreInstaller"
    $requiresVariableSync = $false

    $RmAPI.Bang("[!SetVariable Progress `"25`"][!SetVariable InstallText `"Looking for old files...`"][!UpdateMeterGroup Progress][!Redraw]")

    if ([System.IO.Directory]::Exists("$skinsPath$skin")) {
        debug("Requires variable sync...")
        $RmAPI.Bang("[!SetVariable Progress `"20`"][!SetVariable InstallText `"Removing old files...`"][!UpdateMeterGroup Progress][!Redraw]")
        Copy-Item -LiteralPath "$skinsPath$skin" -Destination "$root\cache\Old$skin" -Force -Recurse

        # Remove-Item "$skinsPath$skin" -Force
        $requiresVariableSync = $true
    }

    if (-not (Test-Path "$root\cache\$skin\VariableFiles.txt")) {
        debug("No VariableFiles.txt found!")
        $requiresVariableSync = $false
    }

    $itemsToCopyFromOld = @()

    if (($requiresVariableSync) -or ($skin -eq 'JaxCore')) {
        $RmAPI.Bang("[!SetVariable Progress `"28`"][!SetVariable InstallText `"Syncing variables...`"][!UpdateMeterGroup Progress][!Redraw]")

        [System.IO.File]::ReadAllLines("$root\cache\$skin\VariableFiles.txt") | ForEach-Object {

            debug('Syncing - ' + $_)

            if (-not [System.IO.File]::Exists("$root\cache\Old$skin\$_")) {
                if (-not [System.IO.File]::Exists("$root\cache\$skin\Skins\$_")) {
                    rmerror("CoreInstaller: Variable file $_ not found! (Error: )")
                    continue
                }
                debug("Not found in old - $_")
            }
            elseif (-not [System.IO.File]::Exists("$root\cache\$skin\Skins\$_")) {
                debug("Not found in new - $_")
                $itemsToCopyFromOld += $_
            }
            else {
                debug("Working on variable file - $_")

                $oldIni = Get-IniContent -filePath "$root\cache\Old$skin\$_"
                $newIni = Get-IniContent -filePath "$root\cache\$skin\Skins\$_"

                $newIniEnum = Get-IniContent -filePath "$root\cache\$skin\Skins\$_"

                foreach ($section in $newIniEnum.GetEnumerator()) {

                    if ($oldIni.Keys -notcontains $section.Key) {
                        debug("$($section.Key) not found in `$oldIni")
                        continue
                    }

                    foreach ($keyvaluepair in $section.Value.GetEnumerator()) {

                        if ($oldIni[$section.Key].Keys -contains $keyvaluepair.Key) {
                            $newIni[$section.Key][$keyvaluepair.Key] = $oldIni[$section.Key][$keyvaluepair.Key]
                        }
                        elseif ($keyvaluepair.Value -match "^\s*\{([^:]+):([^\(\)]+)\((.*)\)\}\s*$") {
                            $sec, $k, $v = $matches[1..3].ToUpper()
                            if ($oldIni.Keys -contains $sec) {
                                if ($oldIni[$sec].Keys -contains $k) {
                                    $newIni[$section.Key][$keyvaluepair.Key] = $oldIni[$sec][$k]
                                }
                                else {
                                    $newIni[$section.Key][$keyvaluepair.Key] = $v
                                }
                            }
                            else {
                                $newIni[$section.Key][$keyvaluepair.Key] = $v
                            }
                        }
                    }
                }

                foreach ($section in $oldIni.GetEnumerator()) {
                    if ($newIni.Keys -notcontains $section.Key) {
                        $newIni[$section.Key] = [ordered]@{}
                    }

                    foreach ($keyvaluepair in $section.Value.GetEnumerator()) {
                        if ($newIni[$section.Key].Keys -notcontains $keyvaluepair.Key) {
                            $newIni[$section.Key][$keyvaluepair.Key] = $keyvaluepair.Value
                        }
                    }
                }

                Set-IniContent -ini $newIni -filePath "$root\cache\$skin\Skins\$_"
            }
        }
    }
    else {
        debug("Skipped variable sync")
        [System.IO.File]::ReadAllLines("$root\cache\$skin\VariableFiles.txt") | ForEach-Object {
            Write-Host $_
            $newIni = Get-IniContent -filePath "$root\cache\$skin\Skins\$_"
            $newIniEnum = $newIni.GetEnumerator()

            foreach ($section in $newIniEnum) {
                foreach ($keyvaluepair in $section.Value.GetEnumerator()) {
                    if ($keyvaluepair.Value -match "^\s*\{([^:]+):([^\(\)]+)\((.*)\)\}\s*$") {
                        $sec, $k, $v = $matches[1..3].ToUpper()
                        $newIni[$section.Key][$keyvaluepair.Key] = $v
                    }
                }
            }

            Set-IniContent -ini $newIni -filePath "$root\cache\$skin\Skins\$_"
        }
    }

    $RmAPI.Bang("[!SetVariable Progress `"60`"][!SetVariable InstallText `"Finalizing variable sync...`"][!UpdateMeterGroup Progress][!Redraw]")

    foreach ($item in $itemsToCopyFromOld) {
        $old = "$root\cache\Old$skin\$item"
        $new = "$root\cache\$skin\Skins\$item"
        [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($new))
        Copy-Item -LiteralPath $old -Destination $new -Force
    }
}