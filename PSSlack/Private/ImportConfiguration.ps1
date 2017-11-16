function ImportConfiguration {
    $Configuration = 
    if(!$Configuration.ClientID -or !$Configuration.ClientSecrets) {
        Write-Warning "Thanks for using the Acme Industries Module, please run Set-AimConfiguration to configure."
        throw "Module not configured. Run Set-AimConfiguration"
    }
    $Configuration
}