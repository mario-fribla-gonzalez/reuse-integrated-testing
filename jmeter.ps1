# Script completo de automatización
param(
    [string]$ParampackageName    = "SinRepo",
    [string]$ParamDeploymentName = "SinRepo"
)

#
Write-Host "Parametros: JMeter"
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
function Install-Java {
    try {
        Write-Host "INFO: Se Procede a Instalar Java JDk 21..."
        Write-Host "INFO: Instalando Java..."
        Expand-Archive -LiteralPath "./requisitos/installjava/jdk-21.0.9.1.zip" -DestinationPath "./requisitos/jdk-21.0.9/" -Force
        Expand-Archive -LiteralPath "./requisitos/installjava/jdk-21.0.9.2.zip" -DestinationPath "./requisitos/jdk-21.0.9/" -Force
        Write-Host "Preparando Variables de Ambientes..."
        $DirActual      = (Get-Location).path
        $Env:JAVA_HOME  = $DirActual + "/requisitos/jdk-21.0.9"
        $Env:JRE_HOME   = $DirActual + "/requisitos/jdk-21.0.9"
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "jdk-21.0.9"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/jdk-21.0.9/bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "jdk-21.0.9"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/jdk-21.0.9/bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser
    }
    catch {
        Write-Host "ERROR(Install-Java): No se Logro Detectar Java JDK: $($_.Exception.Message)"
    }
}

#
function Install-JMeter {
    try {
        Write-Host "INFO: Se Procede a Instalar JMeter..."
        Write-Host "INFO: Instalando JMeter..."
        Expand-Archive -LiteralPath "./requisitos/installjmeter/apache-jmeter-5.6.3.zip" -DestinationPath "./requisitos/" -Force
        Write-Host "Preparando Variables de Ambientes..."
        $DirActual         = (Get-Location).path
        $Env:JMETER_HOME   = $DirActual + "/requisitos/apache-jmeter-5.6.3"
        $Env:JMETER_BIN    = $DirActual + "/requisitos/apache-jmeter-5.6.3\bin\"
        $Env:JM_LAUNCH     = "java.exe"
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "apache-jmeter-5.6.3"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/apache-jmeter-5.6.3\bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "apache-jmeter-5.6.3"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/apache-jmeter-5.6.3\bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser
    
    }
    catch {
        Write-Host "ERROR(Install-JMeter): No se Logro INSTALAR JMeter..."
    }
}

#
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower() + "\NO-TEST"
# Valida si se ejecuta el Test Automatizado.
if ( ( Test-Path $DirTrabajo )) {
    Write-Host "INFO (1): Se Anula Testing. Archivo NO-TEST Encontrado." -ForegroundColor Yellow
    exit 0
} 

# Instalando PreRequisitos.
try {
    $ValidaVersion = java --version
    if ( ( $ValidaVersion ) -and ( $ValidaVersion -like "*java 21.*") ) {
        Write-Host "INFO: JAVA Version Instalada $ValidaVersion ..."
    }
    else {
        Install-Java
        Write-Host "Install-Java(1) Version Java..."
        java --version
    }
}
catch{
    try {
        Install-Java
        Write-Host "Install-Java(2) Version Java..."
        java --version
    }
    catch {
        Write-Host "ERROR: No se Logro Detectar Java JDK: $($_.Exception.Message)"
        exit 1
    }
}

#
try {
    $ValidaVersion = jmeter.bat --version
    if ( $ValidaVersion ) {
        Write-Host "INFO: JMeter Version Instalada $ValidaVersion..."
    }
    else {
        Install-JMeter
        Write-Host "Install-JMeter(1) Version JMeter..."
        jmeter.bat --version
    }
}
catch{
    try{
        Install-JMeter
        Write-Host "Install-JMeter(2) Version JMeter..."
        jmeter.bat --version
    }
    catch{
        Write-Host "ERROR: No se Logro INSTALAR JMeter: $($_.Exception.Message)"
        exit 1
    }
}

#
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower() + "\jmeter"
# Validar Directorio Trabajo + JMeter.
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

$LstArchivos = (Get-ChildItem -File "*.jmx"  | Where-Object { $_.Name -match '^\d' } | Sort-Object Name).Name
foreach ( $IndArchivo in $LstArchivos) {
    $DirActual    = "."
    $RutaDir      = "$DirActual"
    $ArchReport   = "$RutaDir\resultado"

    # Valida o Crea Directorios de Trabajo.
    try {
        # Crear directorio de reports Resultado.
        if ( -not (Test-Path $ArchReport)) {
            New-Item -ItemType Directory -Force -Path $ArchReport
        }
    }
    catch{
        Write-Host "ERROR: No pudo Crear directorio ( $ArchReport )de Reporte JMeter: $($_.Exception.Message)"  
        exit 1
    }
    $ArchReport  = "$ArchReport\$(Get-Date -Format 'yyyyMMdd_HHmmss')_$IndArchivo"
    $ArchReport  = $ArchReport.Replace(".jmx", ".log")
    $ArchResult  = $ArchReport.Replace(".log", ".jtl")
    # Ejecutar Selenium.
    Write-Host "Ejecutando Pruebas  $IndArchivo ..." 
    # Prepara Argumentos para Selenium IDE
    $ArchJMX  = "$DirActual/$IndArchivo"
    try {
        $Result = jmeter.bat -n -t $ArchJMX -j $ArchReport -l $ArchResult
        Write-Host $Result -ForegroundColor Green
    } catch {
        Write-Host "❌ Error ejecutando pruebas: $($_.Exception.Message)"
        exit 1
    }
} ## FOR    

exit 0
