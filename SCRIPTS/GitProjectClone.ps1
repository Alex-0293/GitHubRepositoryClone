<#
    .NOTE
        .AUTHOR AlexK (1928311@tuta.io)
        .DATE   25.05.2020
        .VER    1
        .LANG   En
        
    .LINK
        https://github.com/Alex-0293/GitProjectClone.git
    
    .COMPONENT
        Module: AlexkUtils ( https://github.com/Alex-0293/PS-Modules )

    .SYNOPSIS 

    .DESCRIPTION
        Project to clone multiple projects from github account. 

    .PARAMETER

    .EXAMPLE
        GitProjectClone.ps1

#>
Param (
    
)
clear-host
$Global:ScriptInvocation = $MyInvocation
$InitScript        = "C:\DATA\Projects\GlobalSettings\SCRIPTS\Init.ps1"
. "$InitScript" -MyScriptRoot (Split-Path $PSCommandPath -Parent)
if ($LastExitCode) { exit 1 }

# Error trap
trap {
    if (get-module -FullyQualifiedName AlexkUtils) {
        Get-ErrorReporting $_

        . "$GlobalSettings\$SCRIPTSFolder\Finish.ps1" 
    }
    Else {
        Write-Host "[$($MyInvocation.MyCommand.path)] There is error before logging initialized." -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################





################################# Script end here ###################################
. "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"
