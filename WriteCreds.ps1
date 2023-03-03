function write-username {
    $secret = "myUsername"
    $secureCred = $secret | ConvertTo-SecureString -Force -AsPlainText
    $secureText = $secureCred | ConvertFrom-SecureString

    if (!(Test-Path -Path HKCU:\Software\PsCredentials)) {
      New-Item -Path HKCU:\Software -Name PsCredentials
    }

    Set-ItemProperty -path HKCU:\Software\PsCredentials -Name username -Value $secureText
}

function write-password {
    $secret = "myPasswordIsSecure!"
    $secureCred = $secret | ConvertTo-SecureString -Force -AsPlainText
    $secureText = $secureCred | ConvertFrom-SecureString

    if (!(Test-Path -Path HKCU:\Software\PsCredentials)) {
      New-Item -Path HKCU:\Software -Name PsCredentials
    }

    Set-ItemProperty -path HKCU:\Software\PsCredentials -Name password -Value $secureText
}

function write-some-other-secret {
    $secret = "AnotherSecret"
    $secureCred = $secret | ConvertTo-SecureString -Force -AsPlainText
    $secureText = $secureCred | ConvertFrom-SecureString

    if (!(Test-Path -Path HKCU:\Software\PsCredentials)) {
      New-Item -Path HKCU:\Software -Name PsCredentials
    }

    Set-ItemProperty -path HKCU:\Software\PsCredentials -Name OtherSecret -Value $secureText
}
write-username
write-password
write-some-other-secret