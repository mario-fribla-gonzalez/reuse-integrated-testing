# Script completo de automatización
param(
    [string]$ParampackageName       = "SinRepo",
    [string]$ParamDeploymentName    = "SinRepo",
    [string]$ParamTokenRepositorio  = "SinToken",
    [string]$ParamRepositorioGithub = "SinRepo"
)

Write-Host "Parametros: GitHub Clone QA"
Write-Host "-----------------------"
Write-Host "ParampackageName       : $ParampackageName"
Write-Host "ParamDeploymentName    : $ParamDeploymentName"
Write-Host "ParamTokenRepositorio  : $ParamTokenRepositorio"
Write-Host "ParamRepositorioGithub : $ParamRepositorioGithub"
Write-Host "-----------------------"

#
function Revisa-Path {
    param(
        [string]$RutaPath
      , [string]$PatronPath
    )
    $NuevoPath    = "C:\WINDOWS\system32;D:\Git\cmd;C:\Program Files\Git\bin"
    $tmpRutaPath  = $RutaPath.Replace( $NuevoPath, "")
    $tmpRutaPath  = $RutaPath.Replace( ".;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "%SystemRoot%\system32;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "%SystemRoot%\SysWoW64;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "C:\WINDOWS\system32;", "" )
    $tmpRutaPath  = $tmpRutaPath.Replace( "C:\WINDOWS\SysWoW64;", "" )    
    $RutaSeparada = $tmpRutaPath.Split( ";" )
    foreach ( $Ind in 0..($RutaSeparada.Length - 1) ) {
        $tmpruta  = $RutaSeparada[$Ind]
        if ( $tmpruta.Contains( $PatronPath ) ) {
            Write-Host "Path Existe: Indice: $Ind - Encontrado $tmpruta"
        } else {
            $NuevoPath = $NuevoPath + ";" + $tmpruta
        }
    }
    Write-Host $NuevoPath
    return $NuevoPath
}

function Git-Path {
        $DirActual      = (Get-Location).path
        # Variables Machine
        $tmppathmachine    = [System.Environment]::GetEnvironmentVariable( "PATH", "Machine" )
        $tmpnewpathmachine = Revisa-Path -RutaPath $tmppathmachine -PatronPath "Git"
        $tmpnewpathmachine = $tmpnewpathmachine + ";" + $DirActual
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathmachine, "Machine" )
        # Variables User
        $tmppathuser       = [System.Environment]::GetEnvironmentVariable( "PATH", "User" )
        $tmpnewpathuser    = Revisa-Path -RutaPath $tmppathuser -PatronPath "Git"
        $tmpnewpathuser    = $tmpnewpathuser + ";" + $DirActual
        [Environment]::SetEnvironmentVariable( "PATH", $tmpnewpathuser, "User" )
        $Env:Path          = $tmpnewpathuser    
}
# Instalando PreRequisitos.
try {
    Git-Path
    $ValidaGit = git --version
    if ( $ValidaGit ) {
        Write-Host "INFO: Git Instalado Version $ValidaGit ..."
    }
}
catch{
    Write-Host "ERROR: No se Logro Detectar el Comando GIT: $($_.Exception.Message)"
    exit 1
}

#
$TokenRepositorio  = "$ParamTokenRepositorio"
$RepositorioGithub = "$ParamRepositorioGithub"
$Repositorio       = "https://$TokenRepositorio@$RepositorioGithub"
$RepoGitHubQA      = $ParampackageName.ToLower()
$DirRepoGitHubQA   = "tmpqa"
#$RepoGitHubQA      = "test/" + $RepoGitHubQA

#
try {
    # Crear directorio de Clonamiento.
    if (-not (Test-Path $DirRepoGitHubQA)) {
        New-Item -ItemType Directory -Force -Path $DirRepoGitHubQA
    }
}
catch{
    Write-Host "ERROR: No pudo Crear directorio ( $DirRepoGitHubQA ): $($_.Exception.Message)"  -ForegroundColor Red 
    exit 1
}

#
Write-Host "Clonando Repositorio: $RepoGitHubQA ..."

#
try {
    git clone --branch $RepoGitHubQA --single-branch $Repositorio $DirRepoGitHubQA
    $ResultClone = $LASTEXITCODE
    if ( $ResultClone -eq 0 )  {
        Write-Host "Repositorio Clonado  $RepoGitHubQA ..." -ForegroundColor Green
    } else {
        Write-Host "ERROR: No Existe Branch: $RepoGitHubQA - $( $ResultClone )" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "ERROR: No se Logro Clonar el Repostorio: $RepoGitHubQA - $($_.Exception.Message)"
    exit 1    
}

exit 0

