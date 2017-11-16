function Import-PSSlackConfiguration {
    [cmdletbinding()]
    Param
    (
        [parameter(Mandatory = $false,Position = 0)]
        [String]
        $ConfigName,
        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet("User", "Machine", "Enterprise", $null)]
        [string]
        $Scope = $Script:ConfigScope
    )
    function Decrypt {
        param($String)
        if ($String -is [System.Security.SecureString]) {
            [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
                    $string))
        }
        elseif ($String -is [System.String]) {
            $String
        }
    }
    $script:ConfigScope = $Scope
    $fullConf = Import-SpecificConfiguration -CompanyName 'Unknown' -Name 'PSSlack' -Scope $Script:ConfigScope
    if (!$ConfigName) {
        $choice = $fullConf["DefaultConfig"]
        Write-Verbose "Importing default config: $choice"
    }
    else {
        $choice = $ConfigName
        Write-Verbose "Importing config: $choice"
    }
    $script:PSSlack = [PSCustomObject]($fullConf[$choice]) | 
        Select-Object -Property @{l = 'ArchiveUri';e = {Decrypt $_.ArchiveUri}},
                                @{l = 'Uri';e = {Decrypt $_.Uri}},
                                @{l = 'Token';e = {Decrypt $_.Token}},
                                @{l = 'Proxy';e = {Decrypt $_.Proxy}},
                                @{l = 'ConfigName';e = {$choice}}
    if (!$script:PSSlack) {
        Write-Warning "Unable to import configuration!"
        Write-Host -ForegroundColor Black -BackgroundColor Yellow "Either you are using the incorrect decryption key or you have not created a configuration named '$ConfigName' yet at scope $Scope"
    }
    else {
        Write-Verbose "Imported configuration '$choice' successfully!"
    }
}