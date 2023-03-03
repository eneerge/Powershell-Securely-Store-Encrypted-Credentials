param([string]$action)

# If you prefer to write to a different registry key, you can change it below

function read-username() {
    $secret = Get-ItemPropertyValue -Path HKCU:\Software\PsCredentials -Name username
    $decrypted = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( ( ($secret | ConvertTo-SecureString))))
    return $decrypted
}

function read-password() {
    $secret = Get-ItemPropertyValue -Path HKCU:\Software\PsCredentials -Name password
    $decrypted = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( ( ($secret | ConvertTo-SecureString))))
    return $decrypted
}

function read-some-other-secret() {
    $secret = Get-ItemPropertyValue -Path HKCU:\Software\PsCredentials -Name OtherSecret
    $decrypted = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR( ( ($secret | ConvertTo-SecureString))))
    return $decrypted
}

if ($action -eq "read-username") {
    return read-username
}
if ($action -eq "read-password") {
    return read-password
}
if ($action -eq "read-some-other-secret") {
    return read-some-other-secret
}