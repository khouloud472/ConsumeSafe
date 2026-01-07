#!/bin/bash

# ConsumeSafe Docker Deployment Script (Linux/Mac)
# This script helps deploy ConsumeSafe with Docker Compose

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Command from argument
COMMAND="${1:-basic}"

# Functions
print_colored() {
    local message=$1
    local color=$2
    echo -e "${color}${message}${NC}"
}

check_docker() {
    print_colored "\n[*] Vérification de Docker..." "$CYAN"
    
    if command -v docker &> /dev/null; then
        VERSION=$(docker --version)
        print_colored "✓ Docker trouvé: $VERSION" "$GREEN"
        return 0
    else
        print_colored "✗ Docker n'est pas installé ou accessible" "$RED"
        print_colored "   Installation: https://docs.docker.com/install/" "$YELLOW"
        return 1
    fi
}

check_docker_compose() {
    print_colored "\n[*] Vérification de Docker Compose..." "$CYAN"
    
    if command -v docker-compose &> /dev/null; then
        VERSION=$(docker-compose --version)
        print_colored "✓ Docker Compose trouvé: $VERSION" "$GREEN"
        return 0
    else
        print_colored "✗ Docker Compose n'est pas installé ou accessible" "$RED"
        return 1
    fi
}

check_docker_running() {
    print_colored "\n[*] Vérification que Docker est en cours d'exécution..." "$CYAN"
    
    if docker ps &> /dev/null; then
        print_colored "✓ Docker est en cours d'exécution" "$GREEN"
        return 0
    else
        print_colored "✗ Docker n'est pas en cours d'exécution" "$RED"
        print_colored "   Démarrez le démon Docker" "$YELLOW"
        return 1
    fi
}

show_usage() {
    print_colored "
ConsumeSafe Docker Deployment Script

Usage: $0 [command]

Commands:
  basic       : Démarrer MySQL + ConsumeSafe (par défaut)
  full        : Démarrer MySQL + ConsumeSafe + SonarQube + PostgreSQL
  stop        : Arrêter tous les services
  clean       : Supprimer tous les conteneurs et volumes
  logs        : Afficher les logs en temps réel
  status      : Voir le statut des services
  health      : Voir les health checks des services

Exemples:
  $0 full
  $0 logs
  $0 stop
" "$CYAN"
}

start_basic_stack() {
    print_colored "\n[*] Démarrage de la stack basique (MySQL + ConsumeSafe)..." "$CYAN"
    
    print_colored "\n   Construction de l'image ConsumeSafe..." "$YELLOW"
    docker-compose build
    
    print_colored "\n   Démarrage des services..." "$YELLOW"
    docker-compose up -d
    
    print_colored "\n✓ Services démarrés avec succès!" "$GREEN"
    print_colored "\nServices disponibles:" "$CYAN"
    print_colored "  - ConsumeSafe App: http://localhost:8083" "$GREEN"
    print_colored "  - MySQL: localhost:3306 (user: consumesafe, pwd: consumesafe123)" "$GREEN"
    
    print_colored "\nVérification de l'état des services..." "$YELLOW"
    docker-compose ps
}

start_full_stack() {
    print_colored "\n[*] Démarrage de la stack complète (MySQL + ConsumeSafe + SonarQube + PostgreSQL)..." "$CYAN"
    
    # Check if docker-compose-full.yml exists
    if [ ! -f "docker-compose-full.yml" ]; then
        print_colored "✗ Le fichier docker-compose-full.yml n'existe pas" "$RED"
        print_colored "   Utilisez la commande 'basic' pour commencer" "$YELLOW"
        return 1
    fi
    
    print_colored "\n   Construction de l'image ConsumeSafe..." "$YELLOW"
    docker-compose -f docker-compose-full.yml build
    
    print_colored "\n   Démarrage des services..." "$YELLOW"
    docker-compose -f docker-compose-full.yml up -d
    
    print_colored "\n✓ Services démarrés avec succès!" "$GREEN"
    print_colored "\nServices disponibles:" "$CYAN"
    print_colored "  - ConsumeSafe App: http://localhost:8083" "$GREEN"
    print_colored "  - MySQL: localhost:3306 (user: consumesafe, pwd: consumesafe123)" "$GREEN"
    print_colored "  - SonarQube: http://localhost:9000 (admin/admin)" "$GREEN"
    print_colored "  - PostgreSQL: localhost:5432 (user: sonarqube, pwd: sonarqube)" "$GREEN"
    
    print_colored "\nVérification de l'état des services..." "$YELLOW"
    docker-compose -f docker-compose-full.yml ps
    
    print_colored "\n⚠  SonarQube peut prendre 1-2 minutes pour démarrer complètement..." "$YELLOW"
}

stop_stack() {
    print_colored "\n[*] Arrêt des services..." "$CYAN"
    
    if [ -f "docker-compose-full.yml" ]; then
        print_colored "   Détection: Stack complète (docker-compose-full.yml)" "$YELLOW"
        docker-compose -f docker-compose-full.yml down
    else
        print_colored "   Détection: Stack basique (docker-compose.yml)" "$YELLOW"
        docker-compose down
    fi
    
    print_colored "✓ Services arrêtés" "$GREEN"
}

clean_stack() {
    print_colored "\n[!] Suppression de tous les conteneurs et volumes..." "$YELLOW"
    print_colored "   Cela supprimera toutes les données !" "$RED"
    
    read -p "Êtes-vous sûr? (yes/no) " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_colored "✓ Annulation" "$GREEN"
        return 0
    fi
    
    if [ -f "docker-compose-full.yml" ]; then
        print_colored "   Suppression de la stack complète..." "$YELLOW"
        docker-compose -f docker-compose-full.yml down -v
    else
        print_colored "   Suppression de la stack basique..." "$YELLOW"
        docker-compose down -v
    fi
    
    print_colored "✓ Nettoyage terminé" "$GREEN"
}

show_logs() {
    print_colored "\n[*] Affichage des logs (Ctrl+C pour quitter)..." "$CYAN"
    
    if [ -f "docker-compose-full.yml" ]; then
        docker-compose -f docker-compose-full.yml logs -f
    else
        docker-compose logs -f
    fi
}

show_status() {
    print_colored "\n[*] Statut des services..." "$CYAN"
    
    if [ -f "docker-compose-full.yml" ]; then
        docker-compose -f docker-compose-full.yml ps
    else
        docker-compose ps
    fi
}

show_health() {
    print_colored "\n[*] Vérification des health checks..." "$CYAN"
    
    local containers=("consumesafe-app" "consumesafe-mysql" "consumesafe-sonarqube" "consumesafe-postgres")
    
    for container in "${containers[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "")
            STATUS=$(docker ps --filter "name=$container" --format "{{.State}}" 2>/dev/null || echo "")
            
            if [ -n "$HEALTH" ]; then
                if [ "$HEALTH" = "healthy" ]; then
                    print_colored "  $container : $HEALTH" "$GREEN"
                elif [ "$HEALTH" = "unhealthy" ]; then
                    print_colored "  $container : $HEALTH" "$RED"
                else
                    print_colored "  $container : $HEALTH" "$YELLOW"
                fi
            elif [ -n "$STATUS" ]; then
                if [ "$STATUS" = "running" ]; then
                    print_colored "  $container : $STATUS" "$GREEN"
                else
                    print_colored "  $container : $STATUS" "$YELLOW"
                fi
            fi
        fi
    done
}

# Main script
clear
print_colored "╔════════════════════════════════════════════════════════╗" "$CYAN"
print_colored "║   ConsumeSafe Docker Deployment Script (Linux/Mac)     ║" "$CYAN"
print_colored "╚════════════════════════════════════════════════════════╝" "$CYAN"

# Check prerequisites
if ! check_docker || ! check_docker_compose || ! check_docker_running; then
    show_usage
    exit 1
fi

print_colored "\n[✓] Tous les prérequis sont satisfaits" "$GREEN"

# Execute command
case "$COMMAND" in
    basic)
        start_basic_stack
        ;;
    full)
        start_full_stack
        ;;
    stop)
        stop_stack
        ;;
    clean)
        clean_stack
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    health)
        show_health
        ;;
    *)
        show_usage
        ;;
esac

echo ""
