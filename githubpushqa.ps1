# Script completo de automatización
param(
    [string]$ParampackageName      = "SinRepo",
    [string]$ParamDeploymentName   = "SinRepo"
)

Write-Host "Parametros: GitHub Push QA"
Write-Host "-----------------------"
Write-Host "ParampackageName       : $ParampackageName"
Write-Host "ParamDeploymentName    : $ParamDeploymentName"
Write-Host "-----------------------"

# Instalando PreRequisitos.
try {
    $ValidaGit = git --version
    if ( $ValidaGit ) {
        Write-Host "INFO: Git Instalado Version $ValidaGit ..."
    }
}
catch{
    Write-Host "ERROR: No se Logro Detectar el COmando GIT: $($_.Exception.Message)"
    exit 1
}

#
$RepoGitHubQA     = $ParamDeploymentName.ToLower()
$DirRepoGitHubQA  = "tmpqa/"
$DirRepoTesting   = $DirRepoGitHubQA + $RepoGitHubQA
$FechaTexto       = (Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
$MensajeCommit    = "docs(upgrade): Resultado Pruebas $ParamDeploymentName. V($FechaTexto)"
Write-Host $MensajeCommit
#
try {
    Set-Location $DirRepoTesting
    #
    echo "Validando Branch"
    git branch -r -v -a 
    #
    echo "Prepara Git Push"
    git add .
    git commit -m $MensajeCommit
    git push
}
catch {
    Write-Host "ERROR: No se Logro Realizar Push del Repostorio: $RepoGitHubQA - $($_.Exception.Message)"
    exit 1    
}

#
exit 0
