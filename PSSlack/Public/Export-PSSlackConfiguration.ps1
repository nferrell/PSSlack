function Export-PSSlackConfiguration {
    [cmdletbinding()]
    Param
    (
        [parameter(Mandatory = $false)]
        [ValidateScript( {
                if ($_ -eq "DefaultConfig") {
                    throw "You must specify a ConfigName other than 'DefaultConfig'. That is a reserved value."
                }
                elseif ($_ -notmatch '^[a-zA-Z]+[a-zA-Z0-9]*$') {
                    throw "You must specify a ConfigName that starts with a letter and does not contain any spaces, otherwise the Configuration will break"
                }
                else {
                    $true
                }
            })]
        [string]
        $ConfigName,
        [parameter(Mandatory = $false)]
        [switch]
        $SetAsDefaultConfig,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $Uri,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $Token,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $ArchiveUri,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]
        $Proxy,
        [parameter(Mandatory = $false)]
        [ValidateSet("User", "Machine", "Enterprise", $null)]
        [string]
        $Scope = $script:ConfigScope,
        [parameter(Mandatory = $false)]
        [switch]
        $NoImport
    )
    Begin {
        Function Encrypt {
            param($string)
            if ($string -is [System.Security.SecureString]) {
                $string
            }
            elseif ($string -is [System.String] -and $String -notlike '') {
                ConvertTo-SecureString -String $string -AsPlainText -Force
            }
        }
        $script:ConfigScope = $Scope
        $params = @{}
        if ($PSBoundParameters.Keys -contains "Verbose") {
            $params["Verbose"] = $true
        }
        $configHash = Import-SpecificConfiguration -CompanyName 'Unknown' -Name 'PSSlack' @params
        if (!$ConfigName) {
            $ConfigName = $configHash["DefaultConfig"]
        }
        $configParams = @("Uri","Token","ArchiveUri","Proxy")
        if ($SetAsDefaultConfig) {
            $configHash["DefaultConfig"] = $ConfigName
        }
        if (!$configHash[$ConfigName]) {
            $configHash.Add($ConfigName,(@{}))
        }
        foreach ($key in ($PSBoundParameters.Keys | Where-Object {$configParams -contains $_})) {
            $configHash["$ConfigName"][$key] = (Encrypt $PSBoundParameters[$key])
        }
    }
    Process {
        $exParams = @{}
        if ($Scope) {
            $exParams["Scope"] = $Scope
        }
        $configHash | Export-Configuration @exParams -CompanyName 'Unknown' -Name 'PSSlack'
    }
    End {
        if (!$NoImport) {
            Import-PSSlackConfiguration -ConfigName $ConfigName -Verbose:$false
        }
    }
}