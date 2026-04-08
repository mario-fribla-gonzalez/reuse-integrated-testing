param(
    [string]$ParampackageName    = "SinRepo",
    [string]$ParamDeploymentName = "SinRepo"
)

#
Write-Host "Parametros: Selenium IDE"
Write-Host "---------------------"
Write-Host "ParampackageName    : $ParampackageName"
Write-Host "ParamDeploymentName : $ParamDeploymentName"
Write-Host "---------------------"

#
function Revisa-Path {
    param(
        [string]$RutaPath
      , [string]$PatronPath
    )
    $NuevoPath    = "C:\WINDOWS\system32"
    $tmpRutaPath  = $RutaPath.Replace( ".;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "%SystemRoot%\system32;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "%SystemRoot%\SysWoW64;", "" )
    $RutaSeparada = $tmpRutaPath.Split( ";" )
    foreach ( $Ind in 0..($RutaSeparada.Length - 1) ) {
        $tmpruta  = $RutaSeparada[$Ind]
        if ( $tmpruta.Contains( $PatronPath ) ) {
            Write-Host "Path Existe: Indice: $Ind - Encontrado $tmpruta"
        } else {
            $NuevoPath = $NuevoPath + ";" + $tmpruta
        }
    }
    return $NuevoPath
}

#
function Install-NPM {
    try {
        Write-Host "INFO: Se Procede a Instalar NPM..."
        Write-Host "INFO: Instalando NPM..."
        Expand-Archive -LiteralPath "./requisitos/installpostman/node-v25.2.1-win-x64.zip" -DestinationPath "./requisitos/nodev25/" -Force
        Write-Host "Preparando Variables de Ambientes..."
        $DirActual      = (Get-Location).path
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "nodev25"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/nodev25/node-v25.2.1-win-x64"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "nodev25"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/nodev25/node-v25.2.1-win-x64"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser        
        $DirNPM         = $DirActual + "/requisitos/nodev25/node-v25.2.1-win-x64"
        npm config set prefix $DirNPM
    }
    catch {
        Write-Host "ERROR(Install-NPM): No se Logro Detectar NPM: $($_.Exception.Message)"
    }
}

#
function Install-SELENIUM {
    try {
        Write-Host "INFO: Se Procede a Instalar Selenium..."
        Write-Host "INFO: Instalando Selenium-side-runner..."
        npm install -g selenium-side-runner
        # Instalar Adicionales.
        Write-Host "INFO: Instalando edgedriver..."
        npm install -g edgedriver
        Write-Host "INFO: Instalando geckodriver..."
        npm install -g geckodriver
        Write-Host "Preparando Variables de Ambientes..."
    }
    catch {
        Write-Host "ERROR(Install-SELENIUM): No se Logro Detectar Selenium: $($_.Exception.Message)"
    }
}

#
function Install-Python {
    try {
        Write-Host "INFO: Se Procede a Instalar Python..."
        Write-Host "INFO: Instalando Python..."
        Expand-Archive -LiteralPath "./requisitos/installpython/python-3.13.11-embed-amd64.zip" -DestinationPath "./requisitos/python313/" -Force
        Write-Host "Preparando Variables de Ambientes..."
        $DirActual      = (Get-Location).path
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "python313"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/python313"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/python313/Scripts"        
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "python313"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/python313"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/python313/Scripts"         
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser
    }
    catch {
        Write-Host "ERROR(Install-Python): No se Logro Detectar Python: $($_.Exception.Message)"
    }
}

#
function Install-EDGEDRIVER {
    try {
        Write-Host "INFO: Se Procede a Instalar EDGE DRIVER..."
        Write-Host "INFO: Instalando EDGE DRIVER..."
        npm install -g edgedriver
        Write-Host "Preparando Variables de Ambientes..."
    }
    catch {
        Write-Host "ERROR(Install-EDGEDRIVER): No se Logro Detectar EDGE DRIVER: $($_.Exception.Message)"
    }
}

#
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower() + "\NO-TEST"
# Valida si se ejecuta el Test Automatizado.
if ( ( Test-Path $DirTrabajo )) {
    Write-Host "INFO: Se Anula Testing. Archivo NO-TEST Encontrado." -ForegroundColor Yellow
    exit 0
}

# Instalando PreRequisitos.
try {
    $ValidaNewman = npm -v
    if ( ( $ValidaNewman ) -and ( $ValidaNewman -like "*10.*") ) {
        Write-Host "INFO: NPM Version Instalada $ValidaNewman ..."
    }
    else {
        Install-NPM
        Write-Host "Install-NPM(1) Version NPM..."
        npm -v
    }
}
catch{
    try {
        Install-NPM
        Write-Host "Install-NPM(2) Version NPM..."
        npm -v
    }
    catch {
        Write-Host "ERROR: No se Logro Detectar NPM: $($_.Exception.Message)"
        exit 1
    }
}

#
try {
    $ValidaNewman = selenium-side-runner --version
    if ( $ValidaNewman ) {
        Write-Host "INFO: SELENIUM Version Instalada $ValidaNewman ..."
    }
    else {
        Install-SELENIUM
        Write-Host "Install-SELENIUM(1) Version SELENIUM SIDE..."
        selenium-side-runner --version
    }
}
catch{
    try {
        Install-SELENIUM
        Write-Host "Install-SELENIUM(2) Version SELENIUM SIDE..."
        selenium-side-runner --version
    }
    catch {
        Write-Host "ERROR: No se Logro Detectar SELENIUM SIDE: $($_.Exception.Message)"
        exit 1
    }
}

#
try {
    $ValidaNewman = npm edgedriver --version
    if ( $ValidaNewman ) {
        Write-Host "INFO: EDGEDRIVER Version Instalada $ValidaNewman ..."
    }
    else {
        Install-EDGEDRIVER
        Write-Host "Install-EDGEDRIVER(1) Version EDGE DRIVER..."
        npx edgedriver --version
    }
}
catch{
    try {
        Install-EDGEDRIVER
        Write-Host "Install-EDGEDRIVER(2) Version EDGE DRIVER..."
        npx edgedriver --version
    }
    catch {
        Write-Host "ERROR: No se Logro Detectar EDGE DRIVER: $($_.Exception.Message)"
        exit 1
    }
}

#
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower() + "\seleniumide"
# Validar Directorio Trabajo + SeleniumIDE.
if (-not ( Test-Path $DirTrabajo )) {
    Write-Host "ERROR: Directorio $DirTrabajo NO Existe. Recordar debe ser minuscula. Se Nula Ejecucion..."
    exit 0
}

# Cambia de Directorio.
Set-Location $DirTrabajo
# Valida si se ejecuta el Test Automatizado.
if ( ( Test-Path ".\NO-TEST" )) {
    Write-Host "INFO: Se Anula Testing. Archivo NO-TEST Encontrado." 
    exit 0
}

$LstArchivos = (Get-ChildItem -File "*.side"  | Where-Object { $_.Name -match '^\d' } | Sort-Object Name).Name
foreach ( $IndArchivo in $LstArchivos) {
    #$DirActual    = (Get-Location).path
    $DirActual    = "."
    $RutaDir      = "$DirActual"
    $ArchReport   = "$RutaDir\resultado"
    $ArchPantalla = "$ArchReport\pantalla"

    # Valida o Crea Directorios de Trabajo.
    try {
        # Crear directorio de reports Resultado.
        if ( -not (Test-Path $ArchReport)) {
            New-Item -ItemType Directory -Force -Path $ArchReport
        }
    }
    catch{
        Write-Host "ERROR: No pudo Crear directorio ( $ArchReport )de Reporte Selenium: $($_.Exception.Message)"  
        exit 1
    }
    $ArchPantalla  = "$ArchPantalla\$(Get-Date -Format 'yyyyMMdd_HHmmss')_$IndArchivo"
    $ArchPantalla  = $ArchPantalla.Replace(".side", "")
    try {
        # Crear directorio de reports Resultado.
        if (-not (Test-Path $ArchPantalla)) {
            New-Item -ItemType Directory -Force -Path $ArchPantalla
        }
    }
    catch{
        Write-Host "ERROR: No pudo Crear directorio ( $ArchPantalla )de Pantallas Selenium: $($_.Exception.Message)" 
        exit 1
    }

    # Ejecutar Selenium.
    Write-Host "Ejecutando Pruebas  $IndArchivo ..." 

    # Prepara Argumentos para Selenium IDE
    $ArchSide  = "$DirActual/$IndArchivo"
    $Arguments = @(
       "$ArchSide"
       "--output-directory"            , "$ArchReport"
       "--screenshot-failure-directory", "$ArchPantalla"
       "--timeout"                     , "45000"
    )

    #if ($Headless) {
    #   $Arguments += " --headless"
    #}
    try {
        $Result = selenium-side-runner @Arguments
        Write-Host $Result -ForegroundColor Green
    } catch {
        Write-Host "❌ Error ejecutando pruebas: $($_.Exception.Message)"
        exit 1
    }

} ## FOR

#Write-Host "📁 Reportes y ScreenShot Almacenados en: $ArchReport  y $ArchPantalla "

exit 0
