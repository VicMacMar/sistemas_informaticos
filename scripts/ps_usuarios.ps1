# Ponemos el Domain Component para el dominio
$domain = "dc=campusvera,dc=mylocal"

# Cargar módulo Active Directory si no está cargado
if (!(Get-Module -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# Pedir CSV
$fileUsersCsv = Read-Host "Introduce el fichero csv de los usuarios:"

# Importar CSV con delimitador :
$fichero = Import-Csv -Path $fileUsersCsv -Delimiter ":"

foreach ($linea in $fichero)
{
    # Contraseña
    $passAccount = ConvertTo-SecureString $linea.Password -AsPlainText -Force

    # Nombre completo
    $Surnames = $linea.LastName
    $nameLarge = $linea.Name + " " + $linea.LastName

    # Email
    $email = $linea.Email

    # Habilitado / deshabilitado
    [boolean]$Habilitado = $true
    if ($linea.Enabled -match "false") { $Habilitado = $false }

    # Expiración de cuenta
    $ExpirationAccount = $linea.ExpirationAccount
    $timeExp = (Get-Date).AddDays($ExpirationAccount)

    # Crear usuario
    New-ADUser `
        -SamAccountName $linea.Account `
        -UserPrincipalName $linea.Account `
        -Name $linea.Account `
        -Surname $Surnames `
        -DisplayName $nameLarge `
        -GivenName $linea.Name `
        -Description "Cuenta de $nameLarge" `
        -EmailAddress $email `
        -AccountPassword $passAccount `
        -Enabled $Habilitado `
        -CannotChangePassword $false `
        -ChangePasswordAtLogon $true `
        -PasswordNotRequired $false `
        -Path $linea.Path `
        -AccountExpirationDate $timeExp `
        -LogonWorkstations $linea.Computer

    # Establecer horario de inicio de sesión
    $horassesion = $linea.NetTime -replace(" ","")
    net user $linea.Account /times:$horassesion

    # Añadir al grupo
    $cnGrpAccount = "CN=" + $linea.Group + "," + $linea.Path
    Add-ADGroupMember -Identity $cnGrpAccount -Members $linea.Account
}

Write-Host "Se han creado los usuarios correctamente en el dominio $domain"
