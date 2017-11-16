function Set-ConfigurationKey {
    Param
    (
        [parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
        [ValidateScript({
            if ($_ -is [System.Security.SecureString] -or $_ -is [System.Byte]) {
                $true
            }
            else {
                throw "Key must be a byte array or SecureString!"
            }
        })]
        $Key
    )
    if ($Key -is [System.Security.SecureString]){
        $Method = "SecureString"
    }
    elseif ($Key -is [System.Byte]) {
        $Method = "AES Key"
    }
    Write-Host -ForegroundColor Black -BackgroundColor Magenta "Encryption key set to type: $Method"
    $script:EncryptionKey = $Key
}