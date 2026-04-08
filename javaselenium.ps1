# Script completo de automatización
param(
    [string]$ParampackageName    = "SinRepo",
    [string]$ParamDeploymentName = "SinRepo"
)

#
Write-Host "Parametros: Java Selenium"
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
function Install-Maven {
    try {
        Write-Host "INFO: Se Procede a Instalar Maven..."
        Write-Host "INFO: Instalando Maven..."
        Expand-Archive -LiteralPath "./requisitos/installmavenselenium/apache-maven-3.9.11-bin.zip" -DestinationPath "./requisitos/" -Force
        Write-Host "Preparando Variables de Ambientes..."
        $DirActual      = (Get-Location).path
        $Env:MAVEN_HOME = $DirActual + "/requisitos/apache-maven-3.9.11"
        $Env:M2_HOME    = $DirActual + "/requisitos/apache-maven-3.9.11/bin"
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "apache-maven-3.9.11"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual + "/requisitos/apache-maven-3.9.11/bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "apache-maven-3.9.11"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual + "/requisitos/apache-maven-3.9.11/bin"
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser
    }
    catch {
        Write-Host "ERROR(Install-Maven): No se Logro INSTALAR Maven..."
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
    $ValidaVersion = mvn --version
    if ( $ValidaVersion ) {
        Write-Host "INFO: Maven Version Instalada $ValidaVersion..."
    }
    else {
        Install-Maven
        Write-Host "Install-Maven(1) Version Maven..."
        mvn --version
    }
}
catch{
    try{
        Install-Maven
        Write-Host "Install-Maven(2) Version Maven..."
        mvn --version
    }
    catch{
        Write-Host "ERROR: No se Logro INSTALAR Maven: $($_.Exception.Message)"
        exit 1
    }
}

#
$DirTrabajo = ".\tmpqa\" + $ParamDeploymentName.ToLower() + "\javaselenium"
# Validar Directorio Trabajo + JavaSelenium.
if (-not ( Test-Path $DirTrabajo )) {
    Write-Host "ERROR: Directorio $DirTrabajo NO Existe. Recordar debe ser minuscula. Se Nula Ejecucion..." -ForegroundColor Yellow
    exit 0
}

# Cambia de Directorio.
Set-Location $DirTrabajo
# Valida si se ejecuta el Test Automatizado.
if ( ( Test-Path ".\NO-TEST" )) {
    Write-Host "INFO (2): Se Anula Testing. Archivo NO-TEST Encontrado." -ForegroundColor Yellow
    exit 0
}

$LstArchivos = (Get-ChildItem -File "testng.xml"  |  Sort-Object Name).Name
foreach ( $IndArchivo in $LstArchivos) {
    $DirActual    = (Get-Location).path
    $RutaDir      = "$DirActual"
    $ArchReport   = "$RutaDir\resultado"
    
    # Valida o Crea Directorios de Trabajo.
    try {
        # Crear directorio de reports Resultado.
        if ( -not (Test-Path $ArchReport))
        {  New-Item -ItemType Directory -Force -Path $ArchReport }
    }
    catch{
        Write-Host "ERROR: No pudo Crear directorio ( $ArchReport )de Reporte SQL: $($_.Exception.Message)"  -ForegroundColor Red 
        exit 1
    }
    #    
    # Ejecutar Java Selenium.
    $ArchReport  = "$ArchReport\$(Get-Date -Format 'yyyyMMdd_HHmmss')_$IndArchivo"
    $ArchReport  = $ArchReport.Replace(".xml", ".html")    
    Write-Host "Ejecutando Pruebas  $IndArchivo ..." -ForegroundColor Green
    Write-Host "$$ $IndArchivo : $ArchReport" 
    mvn clean test
    #mvn test

} ## FOR

exit 0