#!/usr/bin/env bash
# ConsumeSafe - Pre-Deployment Checklist Script
# Vérifie que tous les prérequis sont satisfaits avant le déploiement

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ConsumeSafe - Pre-Deployment Checklist   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}\n"

# Helper functions
check_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNINGS++))
}

# 1. Check Java
echo -e "${BLUE}[1/8] Vérification Java${NC}"
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "\K.*?(?=")')
    if [[ $JAVA_VERSION == *"21"* ]]; then
        check_pass "Java 21 installé ($JAVA_VERSION)"
    else
        check_fail "Java version incorrect ($JAVA_VERSION) - Java 21 requis"
    fi
else
    check_fail "Java non installé"
fi

# 2. Check Maven
echo -e "\n${BLUE}[2/8] Vérification Maven${NC}"
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn --version 2>&1 | head -1)
    check_pass "Maven installé ($MVN_VERSION)"
else
    check_fail "Maven non installé"
fi

# 3. Check Git
echo -e "\n${BLUE}[3/8] Vérification Git${NC}"
if command -v git &> /dev/null; then
    check_pass "Git installé"
else
    check_warn "Git non installé (optionnel pour Gitleaks)"
fi

# 4. Check Docker
echo -e "\n${BLUE}[4/8] Vérification Docker${NC}"
if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
        check_pass "Docker installé et actif"
    else
        check_warn "Docker installé mais daemon non démarré"
    fi
else
    check_warn "Docker non installé (optionnel pour containerization)"
fi

# 5. Check project structure
echo -e "\n${BLUE}[5/8] Vérification structure du projet${NC}"
if [ -f "pom.xml" ]; then
    check_pass "pom.xml trouvé"
    
    # Check Java version in pom.xml
    if grep -q "<java.version>21</java.version>" pom.xml; then
        check_pass "pom.xml configuré pour Java 21"
    else
        check_fail "pom.xml non configuré pour Java 21"
    fi
    
    # Check UTF-8 encoding
    if grep -q "<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>" pom.xml; then
        check_pass "pom.xml configuré avec encodage UTF-8"
    else
        check_fail "pom.xml non configuré avec UTF-8"
    fi
else
    check_fail "pom.xml non trouvé"
fi

# 6. Check source files
echo -e "\n${BLUE}[6/8] Vérification fichiers source${NC}"
if [ -f "src/main/java/com/exemple/App.java" ]; then
    check_pass "App.java trouvé"
else
    check_fail "App.java non trouvé"
fi

if [ -f "src/main/java/com/exemple/service/ProductService.java" ]; then
    check_pass "ProductService.java trouvé"
else
    check_fail "ProductService.java non trouvé"
fi

if [ -f "src/main/java/com/exemple/repository/ProductRepository.java" ]; then
    check_pass "ProductRepository.java trouvé"
    
    # Check for new methods
    if grep -q "findByNameIgnoreCase" src/main/java/com/exemple/repository/ProductRepository.java; then
        check_pass "Nouvelles méthodes repository ajoutées"
    else
        check_warn "Méthodes repository ne semblent pas mises à jour"
    fi
else
    check_fail "ProductRepository.java non trouvé"
fi

# 7. Check Docker files
echo -e "\n${BLUE}[7/8] Vérification fichiers Docker${NC}"
if [ -f "Dockerfile" ]; then
    check_pass "Dockerfile trouvé"
    
    if grep -q "eclipse-temurin:21-jre-jammy" Dockerfile; then
        check_pass "Dockerfile configuré pour Java 21"
    else
        check_fail "Dockerfile non configuré pour Java 21"
    fi
else
    check_fail "Dockerfile non trouvé"
fi

if [ -f "docker-compose.yml" ]; then
    check_pass "docker-compose.yml trouvé"
else
    check_fail "docker-compose.yml non trouvé"
fi

# 8. Check Jenkinsfile
echo -e "\n${BLUE}[8/8] Vérification pipeline${NC}"
if [ -f "Jenkinsfile" ]; then
    check_pass "Jenkinsfile trouvé"
    
    if grep -q "mvn org.owasp:dependency-check-maven:check" Jenkinsfile; then
        check_pass "OWASP Dependency Check configuré"
    else
        check_fail "OWASP Dependency Check non configuré"
    fi
else
    check_fail "Jenkinsfile non trouvé"
fi

if [ -f "deploy-pipeline.sh" ]; then
    check_pass "deploy-pipeline.sh trouvé"
else
    check_warn "deploy-pipeline.sh non trouvé (créer avec create_file)"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}Résumé de la vérification:${NC}"
echo -e "${GREEN}  Passés:     ${PASSED}${NC}"
echo -e "${RED}  Échoués:    ${FAILED}${NC}"
echo -e "${YELLOW}  Avertissements: ${WARNINGS}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ Tous les contrôles essentiels sont passés!${NC}"
    echo -e "${BLUE}Vous pouvez procéder au déploiement.${NC}\n"
    exit 0
else
    echo -e "\n${RED}✗ Certains contrôles essentiels ont échoué.${NC}"
    echo -e "${RED}Veuillez corriger les problèmes ci-dessus avant de continuer.${NC}\n"
    exit 1
fi
