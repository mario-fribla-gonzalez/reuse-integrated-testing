
# Script completo de automatización
param(
    [string]$ParampackageName    = "SinRepo",
    [string]$ParamDeploymentName = "SinRepo",
    [string]$ParamReportType     = "htmlextra"
)

#
Write-Host "Parametros: PostMan/NewMan"
Write-Host "---------------------"
Write-Host "ParampackageName    : $ParampackageName"
Write-Host "ParamDeploymentName : $ParamDeploymentName"
Write-Host "ParamReportType     : $ParamReportType"
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
function Install-Newman {
    try {
        Write-Host "INFO: Se Procede a Instalar PostMan/Newman..."
        Write-Host "INFO: Instalando PostMan/Newman..."
        npm install -g newman
        # Instalar Reporters Adicionales
        npm install -g newman-reporter-htmlextra
        npm install -g newman-reporter-html
        Write-Host "Preparando Variables de Ambientes..."
    }
    catch {
        Write-Host "ERROR(Install-PostMan/Newman): No se Logro Detectar PostMan/Newman: $($_.Exception.Message)"
    }
}

$DirTrabajo = $ParamDeploymentName.ToLower() + "\NO-TEST"
# Valida si se ejecuta el Test Automatizado.
if ( ( Test-Path $DirTrabajo )) {
    Write-Host "INFO: Se Anula Testing. Archivo NO-TEST Encontrado." -ForegroundColor Yellow
    exit 0
}

# Instalando PreRequisitos.
try {
    $ValidaVersion = npm -v
    if ( ( $ValidaVersion ) -and ( $ValidaVersion -like "*10.*") ) {
        Write-Host "INFO: NPM Version Instalada $ValidaVersion ..."
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
    $ValidaVersion = newman -v
    if ( $ValidaVersion ) {
        Write-Host "INFO: NEWMAN Version Instalada $ValidaVersion ..."
    }
    else {
        Install-Newman
        Write-Host "Install-Newman(1) Version PostMan/NewMan..."
        newman -v
    }
}
catch{
    try {
        Install-Newman
        Write-Host "Install-Newman(2) Version PostMan/NewMan..."
        newman -v
    }
    catch {
        Write-Host "ERROR: No se Logro Detectar PostMan/NewMan: $($_.Exception.Message)"
        exit 1
    }
}

# Validar Directorio Trabajo + Postman
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower()
if (-not ( Test-Path $DirTrabajo )) {
    Write-Host "ERROR: Directorio $DirTrabajo NO Existe. Recordar debe ser minuscula." -ForegroundColor Red
    exit 1
}

$DirTrabajo = $DirTrabajo + "/postman"
Write-Host "Diretorio: $DirTrabajo"
if (-not ( Test-Path $DirTrabajo )) {
    Write-Host "ERROR: Directorio $DirTrabajo NO Existe. Recordar debe ser minuscula. Se Nula Ejecucion..." -ForegroundColor Yellow
    exit 0
}

# Cambia de Directorio.
Set-Location $DirTrabajo
$Ambiente        = "QA"
$LstArchivos = (Get-ChildItem -File "*.json"  | Where-Object { $_.Name -match '^\d' } | Sort-Object Name).Name
foreach ( $IndArchivo in $LstArchivos) {
    $DirActual = (Get-Location).path
    $RutaDir         = "$DirActual"
    #$ArchCollection  = "$RutaDir/$ParamDeploymentName.json"   ## "$RutaDir/collections/$ParamDeploymentName.json"
    $ArchCollection  = "$RutaDir\$IndArchivo"
    $ArchEnvironment = "$RutaDir\$Ambiente.environment.json"  ## "$RutaDir/environments/$Ambiente.environment.json"
    $ArchReport      = "$RutaDir\resultado"

    # Validar archivos
    if (-not (Test-Path $ArchCollection)) {
        Write-Host "ERROR: Colección no encontrada: $ArchCollection" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $ArchEnvironment)) {
        Write-Host "ERROR: Environment no encontrado: $ArchEnvironment" -ForegroundColor Red
        exit 1
    }

    try {
        # Crear directorio de reports Resultado
        if (-not (Test-Path $ArchReport)) {
            New-Item -ItemType Directory -Force -Path $ArchReport
        }
    }
    catch{
        Write-Host "ERROR: No pudo Crear directorio ( $ArchReport )de Reporte Postman/Newman: $($_.Exception.Message)"  -ForegroundColor Red 
        exit 1
    }

    # Ejecutar Postman/Newman
    $ArchReport  = "$ArchReport\$(Get-Date -Format 'yyyyMMdd_HHmmss')_$IndArchivo"
    $ArchReport  = $ArchReport.Replace(".json", ".html")
    Write-Host "Ejecutando Pruebas  $IndArchivo ..." -ForegroundColor Green

    try{
        $LastExitCode = 0
        $Resultado    = newman run "$ArchCollection" `
        -r $ParamReportType `
        --reporter-htmlextra-export "$ArchReport"  `
        --reporter-htmlextra-title "Reporte de $IndArchivo" `
        --suppress-exit-code
        #-e $ArchEnvironment `
    }
    catch{
        Write-Host "ERROR: No se pudo ejecuta Pruebas Postman/Newman: $($_.Exception.Message)"  -ForegroundColor Red
        exit 1
    }
    
    # Mostrar resultados
    if ($LastExitCode -eq 0) {
        Write-Host "✅ Todas las pruebas pasaron!" -ForegroundColor Green
        Write-Host "$Resultado"
    } else {
        Write-Host "❌ Algunas pruebas fallaron. Código de salida: $LastExitCode" -ForegroundColor Red
    }
    Write-Host "Reporte generado en: $ArchReport"  -ForegroundColor Green

} ## FOR

exit 0
