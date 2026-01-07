# ConsumeSafe Docker Deployment Script (Windows PowerShell)
# This script helps deploy ConsumeSafe with Docker Compose on Windows

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('full', 'basic', 'stop', 'clean', 'logs', 'status', 'health')]
    [string]$Command = 'basic'
)

# Color definitions
$Green = 'Green'
$Yellow = 'Yellow'
$Red = 'Red'
$Cyan = 'Cyan'

function Write-ColorOutput([string]$message, [string]$color = 'White') {
    Write-Host $message -ForegroundColor $color
}

function Check-Docker {
    Write-ColorOutput "`n[*] Vérification de Docker..." $Cyan
    
    try {
        $version = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Docker trouvé: $version" $Green
            return $true
        }
    }
    catch {
        Write-ColorOutput "✗ Docker n'est pas installé ou accessible" $Red
        Write-ColorOutput "   Téléchargez Docker Desktop: https://www.docker.com/products/docker-desktop" $Yellow
        return $false
    }
}

function Check-DockerCompose {
    Write-ColorOutput "`n[*] Vérification de Docker Compose..." $Cyan
    
    try {
        $version = docker-compose --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Docker Compose trouvé: $version" $Green
            return $true
        }
    }
    catch {
        Write-ColorOutput "✗ Docker Compose n'est pas installé ou accessible" $Red
        return $false
    }
}

function Check-DockerRunning {
    Write-ColorOutput "`n[*] Vérification que Docker est en cours d'exécution..." $Cyan
    
    try {
        docker ps >$null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Docker est en cours d'exécution" $Green
            return $true
        }
        else {
            Write-ColorOutput "✗ Docker n'est pas en cours d'exécution" $Red
            Write-ColorOutput "   Démarrez Docker Desktop" $Yellow
            return $false
        }
    }
    catch {
        Write-ColorOutput "✗ Erreur lors de la vérification de Docker" $Red
        return $false
    }
}

function Show-Usage {
    Write-ColorOutput @"
    
ConsumeSafe Docker Deployment Script

Usage: .\start-docker.ps1 -Command <command>

Commands:
  basic       : Démarrer MySQL + ConsumeSafe (par défaut)
  full        : Démarrer MySQL + ConsumeSafe + SonarQube + PostgreSQL
  stop        : Arrêter tous les services
  clean       : Supprimer tous les conteneurs et volumes
  logs        : Afficher les logs en temps réel
  status      : Voir le statut des services
  health      : Voir les health checks des services

Exemples:
  .\start-docker.ps1 -Command full
  .\start-docker.ps1 -Command logs
  .\start-docker.ps1 -Command stop

"@ -ForegroundColor $Cyan
}

function Start-BasicStack {
    Write-ColorOutput "`n[*] Démarrage de la stack basique (MySQL + ConsumeSafe)..." $Cyan
    
    Write-ColorOutput "`n   Construction de l'image ConsumeSafe..." $Yellow
    docker-compose build
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "✗ Erreur lors de la construction de l'image" $Red
        return $false
    }
    
    Write-ColorOutput "`n   Démarrage des services..." $Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "`n✓ Services démarrés avec succès!" $Green
        Write-ColorOutput "`nServices disponibles:" $Cyan
        Write-ColorOutput "  - ConsumeSafe App: http://localhost:8083" $Green
        Write-ColorOutput "  - MySQL: localhost:3306 (user: consumesafe, pwd: consumesafe123)" $Green
        Write-ColorOutput "`nVérification de l'état des services..." $Yellow
        docker-compose ps
        return $true
    }
    else {
        Write-ColorOutput "✗ Erreur lors du démarrage des services" $Red
        return $false
    }
}

function Start-FullStack {
    Write-ColorOutput "`n[*] Démarrage de la stack complète (MySQL + ConsumeSafe + SonarQube + PostgreSQL)..." $Cyan
    
    # Check if docker-compose-full.yml exists
    if (!(Test-Path "docker-compose-full.yml")) {
        Write-ColorOutput "✗ Le fichier docker-compose-full.yml n'existe pas" $Red
        Write-ColorOutput "   Utilisez la commande 'basic' pour commencer" $Yellow
        return $false
    }
    
    Write-ColorOutput "`n   Construction de l'image ConsumeSafe..." $Yellow
    docker-compose -f docker-compose-full.yml build
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "✗ Erreur lors de la construction de l'image" $Red
        return $false
    }
    
    Write-ColorOutput "`n   Démarrage des services..." $Yellow
    docker-compose -f docker-compose-full.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "`n✓ Services démarrés avec succès!" $Green
        Write-ColorOutput "`nServices disponibles:" $Cyan
        Write-ColorOutput "  - ConsumeSafe App: http://localhost:8083" $Green
        Write-ColorOutput "  - MySQL: localhost:3306 (user: consumesafe, pwd: consumesafe123)" $Green
        Write-ColorOutput "  - SonarQube: http://localhost:9000 (admin/admin)" $Green
        Write-ColorOutput "  - PostgreSQL: localhost:5432 (user: sonarqube, pwd: sonarqube)" $Green
        
        Write-ColorOutput "`nVérification de l'état des services..." $Yellow
        docker-compose -f docker-compose-full.yml ps
        
        Write-ColorOutput "`n⚠  SonarQube peut prendre 1-2 minutes pour démarrer complètement..." $Yellow
        return $true
    }
    else {
        Write-ColorOutput "✗ Erreur lors du démarrage des services" $Red
        return $false
    }
}

function Stop-Stack {
    Write-ColorOutput "`n[*] Arrêt des services..." $Cyan
    
    if (Test-Path "docker-compose-full.yml") {
        Write-ColorOutput "   Détection: Stack complète (docker-compose-full.yml)" $Yellow
        docker-compose -f docker-compose-full.yml down
    }
    else {
        Write-ColorOutput "   Détection: Stack basique (docker-compose.yml)" $Yellow
        docker-compose down
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Services arrêtés" $Green
        return $true
    }
    else {
        Write-ColorOutput "✗ Erreur lors de l'arrêt des services" $Red
        return $false
    }
}

function Clean-Stack {
    Write-ColorOutput "`n[!] Suppression de tous les conteneurs et volumes..." $Yellow
    Write-ColorOutput "   Cela supprimera toutes les données !" $Red
    
    $confirm = Read-Host "Êtes-vous sûr? (yes/no)"
    
    if ($confirm -ne 'yes') {
        Write-ColorOutput "✓ Annulation" $Green
        return $true
    }
    
    if (Test-Path "docker-compose-full.yml") {
        Write-ColorOutput "   Suppression de la stack complète..." $Yellow
        docker-compose -f docker-compose-full.yml down -v
    }
    else {
        Write-ColorOutput "   Suppression de la stack basique..." $Yellow
        docker-compose down -v
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Nettoyage terminé" $Green
        return $true
    }
    else {
        Write-ColorOutput "✗ Erreur lors du nettoyage" $Red
        return $false
    }
}

function Show-Logs {
    Write-ColorOutput "`n[*] Affichage des logs (Ctrl+C pour quitter)..." $Cyan
    
    if (Test-Path "docker-compose-full.yml") {
        docker-compose -f docker-compose-full.yml logs -f
    }
    else {
        docker-compose logs -f
    }
}

function Show-Status {
    Write-ColorOutput "`n[*] Statut des services..." $Cyan
    
    if (Test-Path "docker-compose-full.yml") {
        docker-compose -f docker-compose-full.yml ps
    }
    else {
        docker-compose ps
    }
}

function Show-Health {
    Write-ColorOutput "`n[*] Vérification des health checks..." $Cyan
    
    $containers = @('consumesafe-app', 'consumesafe-mysql', 'consumesafe-sonarqube', 'consumesafe-postgres')
    
    foreach ($container in $containers) {
        $exists = docker ps -a --filter "name=$container" --format "{{.Names}}" 2>$null
        if ($exists) {
            $health = docker inspect --format='{{.State.Health.Status}}' $container 2>$null
            $status = docker ps --filter "name=$container" --format "{{.State}}" 2>$null
            
            if ($health) {
                Write-ColorOutput "  $container : $health" $(
                    if ($health -eq "healthy") { $Green } 
                    elseif ($health -eq "unhealthy") { $Red } 
                    else { $Yellow }
                )
            }
            elseif ($status) {
                Write-ColorOutput "  $container : $status" $(
                    if ($status -eq "running") { $Green } else { $Yellow }
                )
            }
        }
    }
}

# Main script
Clear-Host
Write-ColorOutput "╔════════════════════════════════════════════════════════╗" $Cyan
Write-ColorOutput "║     ConsumeSafe Docker Deployment Script (Windows)     ║" $Cyan
Write-ColorOutput "╚════════════════════════════════════════════════════════╝" $Cyan

# Check prerequisites
if (!(Check-Docker) -or !(Check-DockerCompose) -or !(Check-DockerRunning)) {
    Show-Usage
    exit 1
}

Write-ColorOutput "`n[✓] Tous les prérequis sont satisfaits" $Green

# Execute command
switch ($Command) {
    'basic' {
        Start-BasicStack
    }
    'full' {
        Start-FullStack
    }
    'stop' {
        Stop-Stack
    }
    'clean' {
        Clean-Stack
    }
    'logs' {
        Show-Logs
    }
    'status' {
        Show-Status
    }
    'health' {
        Show-Health
    }
    default {
        Show-Usage
    }
}

Write-Host ""
