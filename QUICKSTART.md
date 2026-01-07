# ConsumeSafe - Guide de Démarrage Rapide

## 🚀 Démarrage en 5 Minutes

### Prérequis
- Docker & Docker Compose installés
- OU Maven & Java 21 installés

### Option 1: Avec Docker (Recommandé - Plus Simple)

```bash
# Windows (PowerShell)
.\start-docker-enhanced.ps1 -Command basic

# Linux/Mac
chmod +x start-docker-enhanced.sh
./start-docker-enhanced.sh basic
```

**Services Disponibles**:
- 🌐 App: http://localhost:8083
- 📊 MySQL: localhost:3306 (user: consumesafe, pwd: consumesafe123)

### Option 2: Stack Complète (Avec SonarQube)

```bash
# Windows
.\start-docker-enhanced.ps1 -Command full

# Linux/Mac
./start-docker-enhanced.sh full
```

**Services Additionnels**:
- 📈 SonarQube: http://localhost:9000 (admin/admin)
- 🗄️ PostgreSQL: localhost:5432

### Option 3: Build Local

```bash
# Compiler
mvn clean package

# Lancer
java -jar target/consumesafe-1.0.0.jar
```

---

## 📚 Documentation Complète

- **[DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md)** - Guide détaillé Docker
- **[JENKINS_SETUP.md](JENKINS_SETUP.md)** - Configuration Jenkins CI/CD
- **[COMPLETE_UPGRADE_REPORT.md](COMPLETE_UPGRADE_REPORT.md)** - Rapport complet upgrade Java 21
- **[README.md](README.md)** - Documentation originale du projet

---

## 🔧 Commandes Utiles

### Docker
```bash
# Voir l'état des services
docker-compose ps

# Voir les logs
docker-compose logs -f app

# Arrêter tout
docker-compose down

# Nettoyer (supprimer volumes)
docker-compose down -v
```

### Maven
```bash
# Compiler
mvn clean compile

# Tester
mvn test

# Build
mvn clean package

# Avec profile prod
mvn clean package -Pprod
```

---

## ✅ Checklist de Vérification

- [ ] Docker is running
- [ ] Maven 3.9+ installed
- [ ] Java 21 JDK configured
- [ ] Ports 8083, 3306, 9000 are free
- [ ] Git repository cloned

---

## 🆘 Aide Rapide

| Problème | Solution |
|----------|----------|
| Port déjà utilisé | `docker ps` + `docker kill [container]` |
| Docker not running | Démarrer Docker Desktop |
| Build failure | `mvn clean package -DskipTests` |
| Permission denied | `chmod +x *.sh` |

---

## 📞 Support

Pour plus d'informations, consultez:
1. **DOCKER_DEPLOYMENT.md** (section Troubleshooting)
2. **JENKINS_SETUP.md** (section Troubleshooting)
3. **COMPLETE_UPGRADE_REPORT.md** (section Support)

---

**Status**: ✅ Ready for Production
**Java Version**: 21 LTS
**Last Updated**: January 2025
