# Powershell-Securely-Store-Encrypted-Credentials
This script will allow you to securely store credentials for Powershell, Windows Batch scripts, and any other automation tool that can call PowerShell to complete a task.

There are many alternatives out there that do the job by creating an encrypted file and storing it to disk and then decrypting it at runtime using the key stored in the Windows Cert store. I did not like the idea of storing the encrypted information in a file that can still be accessed by anyone with access to the file structure.

This solution, instead, writes to HKCU registry to store the encrypted information. This solves a couple issues:
- The encrypted information does not reside as a file on the file system (other than the NTUSER.dat registry file)
- The encrypted information is only accessible to the current user running the script
- If a malicious user gets access to a file share, they will only have access to the script code, but they will not be able to retrieve the encrypted credentials. Additionally, the encrypted data will also be unavailable and there will be nothing that can be cracked.

# Installing the secret
1. Download the installer script to a secure location (The installer script will contain your plain text values, so it's important that you keep access to this script restricted and not accessible over the network)
2. Edit the installer script to include your credentials
3. Run the script under the user principal(s) that will need to access the credential
4. Securely delete the installer script or encrypt and store it in a secure location with a password so the plain text can't be easily seen. The installer script file does not need to exist on the server so just delete it or migrate it off the server.

# Using the secrets
1. Download the ReadCreds script and place it in a secure location on the server where the scripts that will be using the creds reside. 
- Recommend this to be outside of your network share if possible.
- Recommend to make the script read-only
- Recommend to remove all write permissions to the file and only allow the "read" permission
2. After installing the secret, the secret will be stored in `HKCU:\Software\keyname you configure`
3. Simply call the "ReadCreds" script with the "action" to read the encrypted value from the registry and decrypt it

# Example 1 - Retrieving secret in a Batch Script
- Credentials have been installed into jsmith's user account using the installer script.
- Jsmith is writing a batch script where he needs to use a password (or client secret key) to access the Azure Graph Api.

In this scenario, Jsmith can retrieve this password using the following code:

`for /f %%i in ('powershell -executionpolicy bypass -Command "E:\securelocation\ReadCreds.ps1 -action read-azure-client-secret"') do set AzureClientSecret=%%i`

This will put the client secret inside of the %AzureClientSecret% variable and it can be used in the script

# Example 2 - Retrieving secret in a Powershell script
- An encrypted database connection string has been installed into jsmith's user account using the installer script.
- Jsmith is creating a powershell script that needs to obtain a database connection string

Jsmith can retrieve the connection string by calling the ReadCreds script directly in his powershell code:

`$dbConnString = E:\securelocation\ReadCreds.ps1 -action read-connString`

#Why Do This?
------------
If a server currently hosts smb file shares on the network, all users on the network could potentially connect to this file share. Although a password is required, exploits in the past have allowed attackers to bypass these settings. In addition, exposed credentials could also lead to an attacker having access to all files that are currently shared on the server.

In the event an attacker does gain access to the file share, they will only have access to the files and directories in the share. They likely will not have the ability to run commands directly on the server or have the ability to query the registry. By requiring the scripts to 1. Read from the registry and 2. Decrypt the secrets using a key that an attacker should not be able to access, we reduce the liklihood of any credentials in our scripts from being exposed.

Additionally, if any files are accessed by a remote user (IE: a batch script), the password information will not appear in the file while they are editing. If an attacker has compromised a user's machine that is accessing one of the files on the share, they will not be able to steal the credentials without first also compromising the server in order to obtain the secret value stored in the registry on the server.


#Possible Vulnerabilities
------------------------
Nothing is perfect. This method suffers from similar vulnerabilities that other solutions suffer from.

If an attacker is able to modify any of the scripts on the system that read credentials, they could theoretically modify them so that they send the decrypted secrets to them (email, tweet, instant message,etc) when they are run.

To prevent this, scripts can be signed using a trusted Certificate Authority and the server be configured to only run signed scripts.

In lieu of signed scripts, a scheduled task could be set up to check for any file changes on the server and a notification be sent once a change occurs and it can be investigated by an administrator.

If you have not mitigated psexec using the TokenFilterPolicy configuration (see https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/user-account-control-and-remote-restriction), psexec could be utilized to read the contents of the registry and/or decrypt the contents if they are able to login with the correct user account.

#Installer Scripts
-------------
The installer scripts contain the plain text credentials that will be encrypted and then written to the HKCU of the user running the script.

For security purposes, these scripts should be migrated off the server and stored in a secure location after use. IE: Use 7-zip to zip them up with AES encryption and a password and move the encrypted archive to your secure store at another location.


#Read Scripts
------------
These scripts read an encrypted value from the registry and decrypt it. They can be called by other scripts/tools to pull in the desired credentials.

#Notes
-------------
The secrets must be installed by each user who will be referencing them. This is because the encryption is based on the user's login and the secrets can only be decrypted by the user who wrote them. The script uses DPAPI to accomplish this task.

For example, if jsmith and jjones need to access a credential, you will need to run the "installer" script for each user account.
When you run the installer script, it writes to the user who is running the script's registry an encrypted value. This encrypted value is only accessible to that user.
Additionally, the encrypted value will be different for each user and each user can only decrypt the data in their own registry.
IE: jsmith will not be able to decrypt jjones' encrypted value even if he were able to see it.
