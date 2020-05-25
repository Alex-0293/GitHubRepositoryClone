# Rename this file to Settings.ps1
######################### value replacement #####################

[string] $Global:Projects            = ""         

######################### no replacement ########################

[string] $Global:ModulePath          = "C:\Program Files\WindowsPowerShell\Modules"
[string] $Global:GlobalSettingsURL   = "https://github.com/Alex-0293/GlobalSettings"
[string] $Global:AlexKUtilsModuleURL = "https://github.com/Alex-0293/PS-Modules"


[bool]  $Global:LocalSettingsSuccessfullyLoaded  = $true
# Error trap
    trap {
        $Global:LocalSettingsSuccessfullyLoaded = $False
        exit 1
    }
