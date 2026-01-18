# ================== VARIABLES ==================

$RutaBase   = "C:\instituto"
$CsvUsuarios = "C:\ProyectoInstituto\usuarios.csv"
$CsvGrupos   = "C:\ProyectoInstituto\grupos.csv"

# ================== CREAR USUARIOS Y GRUPOS ==================

function Crear-Grupos {
    Import-Csv $CsvGrupos | ForEach-Object {
        if (-not (Get-LocalGroup -Name $_.Grupo -ErrorAction SilentlyContinue)) {
            New-LocalGroup -Name $_.Grupo
            Write-Host "Grupo creado:" $_.Grupo
        }
    }
}

function Crear-Usuarios {
    Import-Csv $CsvUsuarios | ForEach-Object {

        $Password = ConvertTo-SecureString $_.Password -AsPlainText -Force

        if (-not (Get-LocalUser -Name $_.Usuario -ErrorAction SilentlyContinue)) {
            New-LocalUser -Name $_.Usuario -Password $Password -PasswordNeverExpires
            Write-Host "Usuario creado:" $_.Usuario
        }

        if ($_.Grupo -ne "") {
            Add-LocalGroupMember -Group $_.Grupo -Member $_.Usuario
        }

        if ($_.Admin -eq "Si") {
            Add-LocalGroupMember -Group "Administradores" -Member $_.Usuario
        }
    }
}

function Ocultar-UsuariosLogin {
    New-ItemProperty `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
        -Name "dontdisplaylastusername" `
        -Value 1 `
        -PropertyType DWORD `
        -Force
}

# ================== CREAR ESTRUCTURA ==================

function Crear-Estructura {

    New-Item -ItemType Directory -Force -Path `
        "$RutaBase\ESO\1ESO",
        "$RutaBase\ESO\2ESO",
        "$RutaBase\ESO\3ESO",
        "$RutaBase\ESO\4ESO",
        "$RutaBase\BACH\1BACH",
        "$RutaBase\BACH\2BACH",
        "$RutaBase\DAW\1DAW"

    Get-ChildItem $RutaBase -Recurse -Directory | ForEach-Object {
        New-Item -ItemType File -Force -Path "$($_.FullName)\trabajo_conjunto.txt"
    }
}

# ================== PERMISOS ==================

function Asignar-Permisos {

    $Base  = "C:\instituto"
    $Admin = "BUILTIN\Administradores"

    # --- RAÍZ ---
    icacls $Base /inheritance:r
    icacls $Base /grant:r `
        "$Admin:F" `
        "SYSTEM:F" `
        "g_1ESO:RX" "g_2ESO:RX" "g_3ESO:RX" "g_4ESO:RX" `
        "g_1BACH:RX" "g_2BACH:RX" `
        "g_1DAW:(OI)(CI)F"

    # --- ETAPAS ---
    foreach ($carp in "ESO","BACH","DAW") {
        icacls "$Base\$carp" /inheritance:r
        icacls "$Base\$carp" /grant:r "$Admin:F" "SYSTEM:F" "g_1DAW:(OI)(CI)F"
    }

    icacls "$Base\ESO"  /grant "g_1ESO:RX"  "g_2ESO:RX"  "g_3ESO:RX"  "g_4ESO:RX"
    icacls "$Base\BACH" /grant "g_1BACH:RX" "g_2BACH:RX"
    icacls "$Base\DAW"  /grant "g_1DAW:(OI)(CI)F"

    # --- CURSOS ESO ---
    icacls "$Base\ESO\1ESO" /inheritance:r
    icacls "$Base\ESO\1ESO" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_1ESO:(OI)(CI)M" `
        "g_2ESO:(OI)(CI)(IO)RX" "g_3ESO:(OI)(CI)(IO)RX" "g_4ESO:(OI)(CI)(IO)RX"

    icacls "$Base\ESO\2ESO" /inheritance:r
    icacls "$Base\ESO\2ESO" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_2ESO:(OI)(CI)M" `
        "g_1ESO:(OI)(CI)(IO)RX" "g_3ESO:(OI)(CI)(IO)RX" "g_4ESO:(OI)(CI)(IO)RX"

    icacls "$Base\ESO\3ESO" /inheritance:r
    icacls "$Base\ESO\3ESO" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_3ESO:(OI)(CI)M" `
        "g_1ESO:(OI)(CI)(IO)RX" "g_2ESO:(OI)(CI)(IO)RX" "g_4ESO:(OI)(CI)(IO)RX"

    icacls "$Base\ESO\4ESO" /inheritance:r
    icacls "$Base\ESO\4ESO" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_4ESO:(OI)(CI)M" `
        "g_1ESO:(OI)(CI)(IO)RX" "g_2ESO:(OI)(CI)(IO)RX" "g_3ESO:(OI)(CI)(IO)RX"

    # --- BACH ---
    icacls "$Base\BACH\1BACH" /inheritance:r
    icacls "$Base\BACH\1BACH" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_1BACH:(OI)(CI)M" "g_2BACH:(OI)(CI)(IO)RX"

    icacls "$Base\BACH\2BACH" /inheritance:r
    icacls "$Base\BACH\2BACH" /grant:r "$Admin:F" "SYSTEM:F" `
        "g_2BACH:(OI)(CI)M" "g_1BACH:(OI)(CI)(IO)RX"

    # --- DAW ---
    icacls "$Base\DAW\1DAW" /inheritance:r
    icacls "$Base\DAW\1DAW" /grant:r "$Admin:F" "SYSTEM:F" "g_1DAW:(OI)(CI)F"
}

# ================== COPIA DE SEGURIDAD (APARTADO 4) ==================

function Copia-Seguridad {

    $Origen = "C:\instituto"
    $DestinoBase = "C:\Backups"

    if (-not (Test-Path $DestinoBase)) {
        New-Item -ItemType Directory -Path $DestinoBase
    }

    $Fecha = Get-Date -Format "yyyyMMdd_HHmmss"
    $Destino = "$DestinoBase\backup_$Fecha"

    Copy-Item -Path $Origen -Destination $Destino -Recurse -Force

    Write-Host "Copia de seguridad creada en: $Destino"
}

# ================== MENU ==================

function Mostrar-Menu {
    Clear-Host
    Write-Host "===== IES Camp de Morvedre ====="
    Write-Host "1. Crear usuarios y grupos"
    Write-Host "2. Crear gestor documental y permisos"
    Write-Host "3. Realizar copia de seguridad"
    Write-Host "s. Salir"
}

do {
    Mostrar-Menu
    $opcion = Read-Host "Selecciona una opción"

    switch ($opcion) {
        '1' {
            Crear-Grupos
            Crear-Usuarios
            Ocultar-UsuariosLogin
            Pause
        }
        '2' {
            Crear-Estructura
            Asignar-Permisos
            Pause
        }
        '3' {
            Copia-Seguridad
            Pause
        }
        's' {
            Write-Host "Saliendo..."
        }
    }
}
until ($opcion -eq 's')
