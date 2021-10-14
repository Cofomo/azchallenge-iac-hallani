#Requires -Version 3.0

if (Get-Module -ListAvailable -Name Az) {
    Write-Host "Module Az exists."
} 
else {
    Write-Host "Module Az does not exist. It will be installed..."

    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force -Verbose -AllowClobber
}