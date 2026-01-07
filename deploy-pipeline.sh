#!/bin/bash

# ConsumeSafe Deployment Pipeline Script (Linux/macOS)
# Cette script simule les étapes du Jenkinsfile pour développement local

set -e

APP_NAME="consumesafe"
DOCKER_IMAGE="consumesafe:latest"
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)
SKIP_TESTS=false
SKIP_DOCKER=false
STAGE="all"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --stage)
            STAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    ConsumeSafe Build & Deployment        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"

# Stage 1: Checkout
stage_checkout() {
    echo -e "\n${YELLOW}[STAGE] Checkout${NC}"
    echo -e "${GREEN}Repository: ConsumeSafe${NC}"
    echo -e "${GREEN}Branch: main${NC}"
}

# Stage 2: Build Maven
stage_build() {
    echo -e "\n${YELLOW}[STAGE] Build Maven${NC}"
    
    if [ "$SKIP_TESTS" = true ]; then
        echo -e "${GREEN}Building without tests...${NC}"
        mvn clean package -DskipTests
    else
        echo -e "${GREEN}Building with tests...${NC}"
        mvn clean package
    fi
    
    echo -e "${GREEN}Build successful!${NC}"
}

# Stage 3: Tests
stage_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        echo -e "\n${YELLOW}[STAGE] Tests - SKIPPED${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}[STAGE] Tests${NC}"
    mvn test
    echo -e "${GREEN}Tests successful!${NC}"
}

# Stage 4: OWASP Dependency Check
stage_owasp() {
    echo -e "\n${YELLOW}[STAGE] Dependency Scan - OWASP${NC}"
    
    echo -e "${GREEN}Running OWASP Dependency Check...${NC}"
    mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7 -DskipProvidedScope=true
    
    echo -e "${GREEN}OWASP scan passed!${NC}"
}

# Stage 5: Docker Build
stage_docker_build() {
    if [ "$SKIP_DOCKER" = true ]; then
        echo -e "\n${YELLOW}[STAGE] Docker Build - SKIPPED${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}[STAGE] Build Docker Image${NC}"
    
    docker build -t $DOCKER_IMAGE .
    docker tag $DOCKER_IMAGE "$DOCKER_IMAGE:$BUILD_NUMBER"
    
    echo -e "${GREEN}Docker image built successfully!${NC}"
}

# Stage 6: Docker Compose Deploy
stage_deploy() {
    if [ "$SKIP_DOCKER" = true ]; then
        echo -e "\n${YELLOW}[STAGE] Deploy - SKIPPED${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}[STAGE] Deploy with Docker Compose${NC}"
    
    docker-compose down -v || true
    docker-compose up -d --build
    
    echo -e "${GREEN}Waiting for services to start...${NC}"
    sleep 5
    
    echo -e "\n${GREEN}[SUCCESS] Application deployed!${NC}"
    echo -e "${CYAN}Access the application at: http://localhost:8083${NC}"
}

# Main execution
trap 'echo -e "\n${RED}Pipeline execution failed!${NC}"; exit 1' ERR

stage_checkout

if [ "$STAGE" = "all" ] || [ "$STAGE" = "build" ]; then
    stage_build
fi

if [ "$STAGE" = "all" ] || [ "$STAGE" = "test" ]; then
    stage_tests
fi

if [ "$STAGE" = "all" ] || [ "$STAGE" = "scan" ]; then
    stage_owasp
fi

if [ "$STAGE" = "all" ] || [ "$STAGE" = "docker" ]; then
    stage_docker_build
    stage_deploy
fi

echo -e "\n${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Pipeline Execution Successful!           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
