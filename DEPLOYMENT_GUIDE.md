# ConsumeSafe - Guide de Déploiement et Pipeline CI/CD

## Résumé de la Mise à Jour Java 21

Ce projet a été mis à jour de **Java 17** à **Java 21 LTS** avec les modifications suivantes :

### Changements Clés

#### 1. **Version Java** 
- **Avant :** Java 17
- **Après :** Java 21 LTS
- **Emplacement JDK :** `C:\Users\khouloud\.jdk\jdk-21.0.8`
- **Configuration :** `pom.xml` - `<java.version>21</java.version>`

#### 2. **Correctifs de Sécurité (CVE)**
- **CVE-2022-45868** - Exposition de mot de passe H2 Console
  - **Avant :** H2 Database 2.1.214
  - **Après :** H2 Database 2.2.220
  - **Validation :** Aucune CVE détectée

#### 3. **Corrections d'Encodage**
- Ajout de `UTF-8` à `pom.xml`
- Suppression de caractères spéciaux/emojis (texte arabe, 🛡️, حماية)
- Configuration du compilateur Maven avec encodage UTF-8

#### 4. **Couche Métier Corrigée**
- **ProductRepository** : Ajout de 6 méthodes de requête
  - `findByNameIgnoreCase(String name)`
  - `findByBarcode(String barcode)`
  - `findByCategoryAndTunisianTrue(String category)`
  - `findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(String, String)`
  - `existsByName(String name)`
  
- **ProductService** : Correction des appels de getter
  - Utilisation de `getBoycotted()` au lieu de `isBoycotted()`

#### 5. **Plugins de Sécurité Intégrés**
- **OWASP Dependency Check** v8.4.2 - Scan des dépendances
- **SonarQube Scanner** v3.10.0.2594 - Analyse SAST
- **Jenkinsfile** - Pipeline DevSecOps complète avec :
  - Gitleaks (scan de secrets)
  - Trivy (scan de conteneurs)
  - Archivage des artefacts

#### 6. **Conteneurisation Docker**
- **Image de base :** eclipse-temurin:21-jre-jammy (Java 21)
- **Multi-stage build :** Optimisé pour réduire la taille

#### 7. **Tests**
- **Résultat :** 4/4 tests passants ✅
  - 2 tests d'intégration (ProductServiceIntegrationTest)
  - 2 tests unitaires (ProductServiceTest)

---

## Guide d'Exécution de la Pipeline

### Option 1 : Déploiement Local (Windows PowerShell)

#### Prérequis
- PowerShell 5.1+
- Maven 3.9.10+
- JDK 21 installé
- Docker & Docker Compose (optionnel, pour le déploiement complet)

#### Commandes

```powershell
# Option A : Construction et tests
.\deploy-pipeline.ps1

# Option B : Construction rapide (sans tests)
.\deploy-pipeline.ps1 -SkipTests

# Option C : Sans Docker
.\deploy-pipeline.ps1 -SkipDocker

# Option D : Stage spécifique
.\deploy-pipeline.ps1 -Stage build
.\deploy-pipeline.ps1 -Stage test
.\deploy-pipeline.ps1 -Stage scan
.\deploy-pipeline.ps1 -Stage docker
```

**Stages disponibles :**
- `all` (défaut) - Tous les stages
- `build` - Maven clean package
- `test` - Tests unitaires
- `scan` - OWASP Dependency Check
- `docker` - Build et déploiement Docker

#### Résultat attendu
```
[STAGE] Checkout
[STAGE] Build Maven
[STAGE] Tests
[STAGE] Dependency Scan - OWASP
[STAGE] Build Docker Image
[STAGE] Deploy

[SUCCESS] Application deployed!
Access the application at: http://localhost:8083
```

---

### Option 2 : Déploiement Local (Linux/macOS)

#### Prérequis
- Bash 4+
- Maven 3.9.10+
- JDK 21 installé
- Docker & Docker Compose

#### Commandes

```bash
# Rendre le script exécutable
chmod +x deploy-pipeline.sh

# Exécution complète
./deploy-pipeline.sh

# Sans tests
./deploy-pipeline.sh --skip-tests

# Stage spécifique
./deploy-pipeline.sh --stage build
./deploy-pipeline.sh --stage docker
```

---

### Option 3 : Pipeline Jenkins (CI/CD)

#### Configuration Jenkins

##### 1. **Prérequis**
- Jenkins 2.387+
- Plugin Pipeline
- Plugin Docker
- Maven tool installé
- JDK 21 configuré

##### 2. **Ajouter le Jenkinsfile**

Dans Jenkins :
1. Créer un nouveau **Pipeline** job
2. **Pipeline script from SCM**
   - SCM : Git
   - Repository URL : `https://github.com/yourusername/ConsumeSafe`
   - Credentials : Ajouter les credentials GitHub
   - Branch : `*/main`
   - Script path : `Jenkinsfile`

##### 3. **Configuration des Variables Environnement**

Dans **Jenkins > Système > Variables Globales Configurées** :

```
DOCKER_REGISTRY_URL=docker.io
DOCKER_REGISTRY_USER=your-docker-username
SONARQUBE_ENABLED=false  (ou true si SonarQube disponible)
GITLEAKS_ENABLED=false   (ou true si Gitleaks installé)
TRIVY_ENABLED=false      (ou true si Trivy installé)
```

##### 4. **Exécution de la Pipeline**

- Cliquer sur **Build Now**
- La pipeline exécutera :
  1. ✅ Checkout
  2. ✅ Build Maven (mvn clean package)
  3. ✅ Tests (mvn test)
  4. 🟡 SonarQube (si SONARQUBE_ENABLED=true)
  5. ✅ OWASP Dependency Check (mvn dependency-check)
  6. 🟡 Gitleaks (si GITLEAKS_ENABLED=true)
  7. ✅ Docker Build
  8. 🟡 Trivy (si TRIVY_ENABLED=true)
  9. 🟡 Push Registry (si branche main)
  10. ✅ Deploy (Docker Compose sur main)

---

## Configuration des Services Externes (Optionnel)

### SonarQube

```bash
# Démarrer SonarQube (Docker)
docker run -d \
  --name sonarqube \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLED=true \
  -p 9000:9000 \
  sonarqube:10-community

# Puis activer dans Jenkins/Jenkinsfile
SONARQUBE_ENABLED=true
```

### Gitleaks

```bash
# Installation
brew install gitleaks  # macOS
# ou
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.1/gitleaks-linux-x64
chmod +x gitleaks-linux-x64

# Activation dans Jenkinsfile
GITLEAKS_ENABLED=true
```

### Trivy

```bash
# Installation
brew install aquasecurity/trivy/trivy  # macOS
# ou
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Activation dans Jenkinsfile
TRIVY_ENABLED=true
```

---

## Accès à l'Application

### URL locales
- **Application Web :** http://localhost:8083
- **H2 Console (DEV) :** http://localhost:8083/h2-console
  - JDBC URL : `jdbc:h2:mem:testdb`
  - Username : `sa`
  - Password : (vide)

### Credentials MySQL (Docker)
- **Host :** localhost:3306
- **Database :** consumesafe
- **Username :** consumesafe
- **Password :** consumesafe123

---

## Structure de la Pipeline

```
ConsumeSafe
├── Jenkinsfile (CI/CD)
├── Dockerfile (Conteneurisation)
├── docker-compose.yml (Orchestration)
├── deploy-pipeline.ps1 (Windows automation)
├── deploy-pipeline.sh (Linux/macOS automation)
├── pom.xml (Build & Security plugins)
├── src/
│   ├── main/java/com/exemple/
│   │   ├── App.java
│   │   ├── config/
│   │   │   ├── CorsConfig.java
│   │   │   └── DataInitializer.java
│   │   ├── controller/
│   │   │   ├── ProductController.java
│   │   │   └── WebController.java
│   │   ├── service/
│   │   │   └── ProductService.java (CORRIGÉ)
│   │   ├── repository/
│   │   │   └── ProductRepository.java (AMÉLIORÉ)
│   │   ├── model/
│   │   │   ├── Product.java
│   │   │   └── Alternative.java
│   │   └── dto/
│   │       └── ProductCheckResponse.java
│   └── test/
│       ├── java/com/exemple/
│       │   ├── ProductServiceIntegrationTest.java
│       │   └── ProductServiceTest.java
│       └── resources/
│           └── application-test.properties (NOUVEAU)
└── init-db.sql (Initialisation BD)
```

---

## Troubleshooting

### Erreur : "SonarQube server can not be reached"
**Cause :** SonarQube n'est pas actif
**Solution :** 
- Ajouter `SONARQUBE_ENABLED=false` dans les variables Jenkins
- Ou démarrer SonarQube avec Docker

### Erreur : "Maven not found"
**Cause :** Maven non installé ou non dans PATH
**Solution :**
```bash
# Télécharger Maven 3.9.10
wget https://archive.apache.org/dist/maven/maven-3/3.9.10/binaries/apache-maven-3.9.10-bin.tar.gz
# Extraire et ajouter au PATH
```

### Erreur : "Docker daemon is not running"
**Cause :** Docker service arrêté
**Solution :**
```bash
# Windows
Start-Service Docker

# Linux
sudo systemctl start docker

# macOS
open -a Docker
```

### Tests échouent avec erreur encoding
**Cause :** Fichier source avec caractères non-ASCII
**Solution :** Vérifier que UTF-8 est configuré dans pom.xml
```xml
<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
```

---

## Validation de la Configuration

### Vérifier Java 21
```bash
java -version
# Output: openjdk version "21.0.8" 2024-07-16 LTS
```

### Vérifier Maven
```bash
mvn --version
# Output: Maven 3.9.10
```

### Vérifier la build
```bash
mvn clean compile
# BUILD SUCCESS
```

### Vérifier les tests
```bash
mvn test
# BUILD SUCCESS - 4 tests passants
```

### Vérifier l'image Docker
```bash
docker images | grep consumesafe
# REPOSITORY TAG IMAGE ID CREATED SIZE
# consumesafe latest xxxxx 2 hours ago 587MB
```

---

## Checkpoint Avant Déploiement

- [ ] Java 21 JDK installé et configuré
- [ ] Maven 3.9.10+ disponible
- [ ] `mvn clean package` réussit
- [ ] 4 tests unitaires passent
- [ ] OWASP Dependency Check sans erreur
- [ ] Docker image se construit sans erreur (optionnel)
- [ ] Docker Compose démarre tous les services (optionnel)
- [ ] Application accessible sur http://localhost:8083

---

## Prochaines Étapes

1. **Développement Local :**
   ```powershell
   # Windows
   .\deploy-pipeline.ps1 -SkipTests -SkipDocker
   ```

2. **Tests Complets :**
   ```powershell
   # Avec tests
   .\deploy-pipeline.ps1
   ```

3. **Production Docker :**
   ```bash
   docker-compose up -d
   # Application disponible à http://localhost:8083
   ```

4. **Integration CI/CD :**
   - Configurer Jenkins avec le Jenkinsfile
   - Activer les scans optionnels (SonarQube, Gitleaks, Trivy)
   - Configurer le push vers un registre Docker

---

## Informations de Contrat

| Propriété | Valeur |
|-----------|--------|
| **Java Version** | 21 LTS |
| **Maven** | 3.9.10+ |
| **Spring Boot** | 3.2.0 |
| **Base de Données** | MySQL 8.0.36 (prod) / H2 (test) |
| **Port Application** | 8083 |
| **Port MySQL** | 3306 |
| **Port SonarQube** | 9000 |
| **Build Artifact** | target/consumesafe-1.0.0.jar |

---

## Support

Pour les problèmes ou questions :
1. Vérifier les logs : `docker-compose logs -f app`
2. Vérifier la build locale : `mvn clean compile`
3. Vérifier la configuration Docker : `docker ps`
4. Vérifier les dépendances : `mvn dependency:tree`

---

**Dernière mise à jour :** 2024-01-XX
**Status :** ✅ Prêt pour déploiement
