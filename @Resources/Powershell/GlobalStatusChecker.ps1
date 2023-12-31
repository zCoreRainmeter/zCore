$skinList = $RmAPI.VariableStr('SkinList')
$resources = $RmAPI.VariableStr('@')
$skinspath = $RmAPI.VariableStr('Skinspath')
$root = $RmAPI.VariableStr('ROOTCONFIGPATH')
$exportTo = $resources + 'Includes\GlobalVersionList.inc'

# $RmAPI.Log($RmAPI.VariableStr('LastRollBackSkin'))
# $RmAPI.Log("$skinName|$skinVer")

function Print-Skin ([string] $Text) {
    $RmAPI.Bang("[!SetOption Header.Description Text `"`"`"$Text`"`"`"][!UpdateMeter Header.Description][!Redraw]")
}

function rmlog ($Text) {
  $RmAPI.Log($Text)
}

# ---------------------------------------------------------------------------- #
#                                Write functions                               #
# ---------------------------------------------------------------------------- #

function Write-Eq($i, $name, $version) {
    $global:exportString += @"
[List.Item$i.Shape]
Meter=Shape
LeftMouseUpAction=[!WriteKeyvalue Variables Skin.Name "$name" "#@#CacheVars\Configurator.inc"][!WriteKeyvalue Variables Skin.Set_Page Info "#@#CacheVars\Configurator.inc"][!ActivateConfig "#JaxCore\Main" "Settings.ini"][!DeactivateConfig]
MeterStyle=List.Item.Shape:S
[List.Item$i.Title.String]
Meter=String
Text=$name
MeterStyle=Sec.String:S | List.Item.Title.String:S
[List.Item$i.VersionDiff.String]
Meter=String
Text="$version ✔️"
MeterStyle=Sec.String:S | List.Item.VersionDiff.String:S
[List.Item$i.Button.Shape]
Meter=Shape
Hidden=1
MeterStyle=List.Item.Button_Eq.Shape:S
[List.Item$i.Button.String]
Meter=String
Hidden=1
MeterStyle=Sec.String:S | List.Item.Button.String:S

"@
}
function Write-Gt($i, $name, $version1, $version2) {
    $global:exportString += @"
[List.Item$i.Shape]
Meter=Shape
LeftMouseUpAction=[!WriteKeyvalue Variables Skin.Name "$name" "#@#CacheVars\Configurator.inc"][!WriteKeyvalue Variables Skin.Set_Page Info "#@#CacheVars\Configurator.inc"][!ActivateConfig "#JaxCore\Main" "Settings.ini"][!DeactivateConfig]
MeterStyle=List.Item.Shape:S
[List.Item$i.Title.String]
Meter=String
Text=$name
MeterStyle=Sec.String:S | List.Item.Title.String:S
[List.Item$i.VersionDiff.String]
Meter=String
Text="$version1 >> $version2 ⚠️"
MeterStyle=Sec.String:S | List.Item.VersionDiff.String:S
[List.Item$i.Button.Shape]
Meter=Shape
LeftMouseDownAction=[!SetVariable DownloadLink "https://github.com/Jax-Core/$name/releases/download/v$version2/$($name)_v$($version2).rmskin"][!SetVariable DownloadName "$name$($version2)"][!SetVariable DownloadConfig "$name"][!CommandMeasure CoreInstallHandler "InitInstall"]
MeterStyle=List.Item.Button_Gt.Shape:S
[List.Item$i.Button.String]
Meter=String
Text=[\xe884]
MeterStyle=Sec.String:S | List.Item.Button.String:S

"@
}
function Write-Dev($i, $name, $version) {
    $global:exportString += @"
[List.Item$i.Shape]
Meter=Shape
LeftMouseUpAction=[!WriteKeyvalue Variables Skin.Name "$name" "#@#CacheVars\Configurator.inc"][!WriteKeyvalue Variables Skin.Set_Page Info "#@#CacheVars\Configurator.inc"][!ActivateConfig "#JaxCore\Main" "Settings.ini"][!DeactivateConfig]
MeterStyle=List.Item.Shape:S
[List.Item$i.Title.String]
Meter=String
Text=$name
MeterStyle=Sec.String:S | List.Item.Title.String:S
[List.Item$i.VersionDiff.String]
Meter=String
Text="$version 🛠️"
MeterStyle=Sec.String:S | List.Item.VersionDiff.String:S
[List.Item$i.Button.Shape]
Meter=Shape
Hidden=1
MeterStyle=List.Item.Button_Eq.Shape:S
[List.Item$i.Button.String]
Meter=String
Hidden=1
MeterStyle=Sec.String:S | List.Item.Button.String:S

"@
}
function Write-NA($i, $name) {
    $global:exportString += @"
[List.Item$i.Shape]
Meter=Shape
LeftMouseUpAction=[!WriteKeyvalue Variables Skin.Name "$name" "#@#CacheVars\Configurator.inc"][!WriteKeyvalue Variables Skin.Set_Page Info "#@#CacheVars\Configurator.inc"][!ActivateConfig "#JaxCore\Main" "Settings.ini"][!DeactivateConfig]
MeterStyle=List.Item.Shape:S
[List.Item$i.Title.String]
Meter=String
Text=$name
FontColor=#Set.Subtext_Color#
MeterStyle=Sec.String:S | List.Item.Title.String:S
[List.Item$i.VersionDiff.String]
Meter=String
Text="Not installed ❌"
MeterStyle=Sec.String:S | List.Item.VersionDiff.String:S
[List.Item$i.Button.Shape]
Meter=Shape
Hidden=1
MeterStyle=List.Item.Button_Eq.Shape:S
[List.Item$i.Button.String]
Meter=String
Hidden=1
MeterStyle=Sec.String:S | List.Item.Button.String:S

"@
}

# ---------------------------------------------------------------------------- #
#                                    Process                                   #
# ---------------------------------------------------------------------------- #

if (-not ($RmAPI.VariableStr('Parsed') -match '1')) {
    # Print-Skin "Converting to array"
    $SkinArray = $SkinList -split '\s\|\s'
    # Print-Skin "Checking for installation"
    for ($i=0; $i -lt $SkinArray.Count; $i++) {
        If (Test-Path -Path "$($skinspath)$($SkinArray[$i])\") {
            try {
                Print-Skin "Checking remote $($SkinArray[$i]) version..."
                $response = Invoke-WebRequest "https://raw.githubusercontent.com/Jax-Core/$($SkinArray[$i])/main/%40Resources/Version.inc" -UseBasicParsing
                $responseBytes = $response.RawContentStream.ToArray()
                if ([System.Text.Encoding]::Unicode.GetString($responseBytes) -match 'Version=(.+)') {
                    $latest_v = $matches[1]
                }
            } catch {
                rmlog "$($SkinArray[$i]) repository does not exist or is hidden"
                $latest_v = '0.0'
            } finally {
                Get-Content "$($skinspath)$($SkinArray[$i])\@Resources\Version.inc" -Raw | Select-String -Pattern '\d\.\d+' -AllMatches | Foreach-Object {$local_v = $_.Matches.Value}
                rmlog "$($SkinArray[$i]) ✔️ - 🔼 |$latest_v| 🔽 |$local_v|"
                if ($latest_v -eq $local_v) {
                    Write-Eq $i $SkinArray[$i] $local_v
                } elseif ($latest_v -gt $local_V) {
                    Write-Gt $i $SkinArray[$i] $local_v $latest_v
                } else {
                    Write-Dev $i $SkinArray[$i] $local_v
                }
            }
            
        } else {
            rmlog "$($SkinArray[$i]) ❌"
            Write-NA $i $SkinArray[$i]
        }
    }
    $global:exportString | Out-File -filePath $exportTo -Force -Encoding unicode
    $RmAPI.Bang('[!WriteKeyValue Variables Parsed 1 "'+$root+'Accessories\GenericWindow\Variants\GlobalStatusChecker.inc"][!Refresh]')
} else {
    $blank = ""
    $blank | Out-File -filePath $exportTo -Force -Encoding unicode
    $RmAPI.Bang('[!WriteKeyValue Variables Parsed 0 "'+$root+'Accessories\GenericWindow\Variants\GlobalStatusChecker.inc"]')
}
