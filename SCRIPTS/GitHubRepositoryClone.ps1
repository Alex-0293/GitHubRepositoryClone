﻿<#
    .NOTES
        AUTHOR AlexK (1928311@tuta.io)
        DATE   25.05.2020
        VER    1
        LANG   En
        
    .LINK
        https://github.com/Alex-0293/GitProjectClone.git
    
    .COMPONENT
        Module: AlexkUtils ( https://github.com/Alex-0293/PS-Modules )


    .SYNOPSIS 

    .DESCRIPTION
        Project to clone multiple projects from github account. 

    

    .EXAMPLE
        GitProjectClone.ps1

#>
Param (
    [Parameter( Mandatory = $false, Position = 0, HelpMessage = "Initialize global settings." )]
    [bool] $InitGlobal = $true,
    [Parameter( Mandatory = $false, Position = 1, HelpMessage = "Initialize local settings." )]
    [bool] $InitLocal = $true   
)

$Global:ScriptInvocation = $MyInvocation
if ($env:AlexKFrameworkInitScript){
    . "$env:AlexKFrameworkInitScript" -MyScriptRoot (Split-Path $PSCommandPath -Parent) -InitGlobal $InitGlobal -InitLocal $InitLocal
} Else {
    Write-host "Environmental variable [AlexKFrameworkInitScript] does not exist!" -ForegroundColor Red
     exit 1
}
if ($LastExitCode) { exit 1 }

# Error trap
trap {
    if (get-module -FullyQualifiedName AlexkUtils) {
        Get-ErrorReporting $_

        . "$($Global:gsGlobalSettingsPath)\$($Global:gsSCRIPTSFolder)\Finish.ps1" 
    }
    Else {
        Write-Host "[$($MyInvocation.MyCommand.path)] There is error before logging initialized. Error: $_" -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################

$Res = Import-Module PowerShellForGitHub -PassThru
if ( (-not $res) -and (-not (Get-Module -FullyQualifiedName PowerShellForGitHub)) ) {
    Add-ToLog -Message "Installing module [PowerShellForGitHub]." -Display -Status "Info" -logFilePath $Global:gsScriptLogFilePath
    gsudo Install-Module -Name PowerShellForGitHub
    Set-GitHubAuthentication
    $Res = Import-Module PowerShellForGitHub -PassThru
}
if (-not $Res) {
    Add-ToLog -Message "Module [PowerShellForGitHub] import unsuccessful!" -Display -Status "Error" -logFilePath $Global:gsScriptLogFilePath 
    exit 1
}
Else {
    if (-not (Get-GitHubConfiguration -name DisableTelemetry)) {
        Set-GitHubConfiguration  -DisableTelemetry -SessionOnly
    }
}

$res = Get-GitHubRepository  #-Uri "https://github.com/Alex-0293"
[array] $ProjectList = @()
foreach ($ProjectFolders in $Global:SearchProjectsPath){
   $Folders = Get-ChildItem $ProjectFolders -Directory
   foreach ($Folder in $Folders){
        if ( -not ($global:FoldersToIgnoreName -contains $Folder.Name)){
            $ProjectList += $Folder
        }
   } 
}

foreach ($Item in $Res) {
    if ($ProjectList.name -contains $Item.name){
        $Item | Add-Member –MemberType NoteProperty –name Exist –value $true
    }
    else {
        $Item | Add-Member –MemberType NoteProperty –name Exist –value $false 
    }
}

  
$Answer = $Res |Where-Object {$_.exist -eq $false} | Select-Object id, name, exist, private, description, fork, created_at, updated_at, size, stargazers_count, watchers_count, language, forks_count, archived, disabled, license, clone_url | Out-GridView -Title "Select projects for clone locally." -PassThru
if ($Answer) {
    $Global:gsProjectsFolderPath = $Global:SearchProjectsPath | Out-GridView  -Title "Select destination folder." -OutputMode Single
    if (-not (Test-Path $($Global:gsProjectsFolderPath)) ){
        Add-ToLog -Message "Path [$($($Global:gsProjectsFolderPath))] does not exist!" -Display -Status "Error" -logFilePath $Global:gsScriptLogFilePath 
        exit 1
    }
    $Answer | Select-Object id, name, private, clone_url | Format-Table -AutoSize
    foreach ($item in $Answer){
        if (Test-Path "$($($Global:gsProjectsFolderPath))\$($item.name)") {
            Add-ToLog -Message "Repository [$($item.name)] cloning unsuccessful, path already exist!" -Display -Status "Error" -logFilePath $Global:gsScriptLogFilePath            
        }
        else {
            Add-ToLog -Message "Cloning repository [$($item.name)]." -Display -Status "Info" -logFilePath $Global:gsScriptLogFilePath
            Set-Location $($Global:gsProjectsFolderPath)
            & git.exe clone $item.clone_url
            if ( Test-Path "$($($Global:gsProjectsFolderPath))\$($item.name)\$Global:gsSETTINGSFolder\$($Global:gsEmptySettingsFile)") {
                Add-ToLog -Message "Copying empty settings file [$($Global:gsProjectsFolderPath)\$($item.name)\$($Global:gsSETTINGSFolder)\$($Global:gsEmptySettingsFile)] to [$($Global:gsProjectsFolderPath)\$($item.name)\$($Global:gsSETTINGSFolder)\$($Global:gsDefaultSettingsFile)]." -Display -Status "Info" -logFilePath $Global:gsScriptLogFilePath
                Copy-Item -path "$($Global:gsProjectsFolderPath)\$($item.name)\$($Global:gsSETTINGSFolder)\$($Global:gsEmptySettingsFile)" -Destination "$($Global:gsProjectsFolderPath)\$($item.name)\$($Global:gsSETTINGSFolder)\$($Global:gsDefaultSettingsFile)"
                Remove-Item -path "$($Global:gsProjectsFolderPath)\$($item.name)\$($Global:gsSETTINGSFolder)\$($Global:gsEmptySettingsFile)" -Force
            }
        }
    }
}

################################# Script end here ###################################
. "$($Global:gsGlobalSettingsPath)\$($Global:gsSCRIPTSFolder)\Finish.ps1"
