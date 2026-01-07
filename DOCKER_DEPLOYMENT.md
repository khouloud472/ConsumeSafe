# Docker Deployment Guide for ConsumeSafe

## Overview

Ce guide explique comment déployer ConsumeSafe avec tous ses services en utilisant Docker Compose.

## Prérequis

1. **Docker** installé (version 20.10 ou supérieure)
   - Windows: Docker Desktop (https://www.docker.com/products/docker-desktop)
   - Linux: `sudo apt-get install docker.io docker-compose`

2. **Docker Compose** installé
   - Inclus dans Docker Desktop pour Windows/Mac
   - Linux: `sudo apt-get install docker-compose`

3. **Git** pour cloner le repository (optionnel)

## Structure des Services

### 1. MySQL Database
- **Port**: 3306
- **Base de données**: consumesafe
- **Utilisateur**: consumesafe
- **Mot de passe**: consumesafe123
- **Volume**: `mysql_data` (persistant)
- **Santé**: Health check toutes les 10s

### 2. ConsumeSafe Application
- **Port**: 8083
- **Base image**: Basée sur Java 21 JRE
- **Dépendances**: MySQL
- **Profil**: prod
- **Mémoire JVM**: 75% de la limite du conteneur (max 2GB)
- **Garbage Collector**: G1GC avec pause max 200ms

### 3. PostgreSQL (Pour SonarQube)
- **Port**: 5432
- **Base de données**: sonarqube
- **Utilisateur**: sonarqube
- **Mot de passe**: sonarqube
- **Volume**: `postgres_data` (persistant)
- **Image**: postgres:15-alpine

### 4. SonarQube Server
- **Port**: 9000
- **URL**: http://localhost:9000
- **Base de données**: PostgreSQL (postgres:5432)
- **Credentials par défaut**: admin/admin
- **Volume**: sonarqube_data, sonarqube_logs, sonarqube_extensions

## Démarrage

### Option 1: Docker Compose Standard (MySQL + App)

```bash
# Depuis le répertoire racine du projet
docker-compose up -d

# Vérifier les services
docker-compose ps

# Voir les logs
docker-compose logs -f app
docker-compose logs -f mysql
```

### Option 2: Docker Compose Complet (MySQL + App + SonarQube)

```bash
# Démarrer tous les services
docker-compose -f docker-compose-full.yml up -d

# Vérifier les services
docker-compose -f docker-compose-full.yml ps

# Voir les logs
docker-compose -f docker-compose-full.yml logs -f

# Voir les logs d'un service spécifique
docker-compose -f docker-compose-full.yml logs -f app
docker-compose -f docker-compose-full.yml logs -f sonarqube
```

## Vérification des Services

### Application ConsumeSafe
```bash
# Attendre 30-60 secondes après le démarrage
curl http://localhost:8083

# Ou visiter dans le navigateur:
# http://localhost:8083
```

### Base de données MySQL
```bash
# Se connecter à MySQL
docker exec -it consumesafe-mysql mysql -u consumesafe -pconsumesafe123 -D consumesafe

# Vérifier les tables
SHOW TABLES;
SELECT * FROM products LIMIT 5;
```

### SonarQube
```bash
# Accéder à l'interface web
# http://localhost:9000

# Credentials par défaut: admin/admin
```

## Configuration de SonarQube

### Première connexion

1. Accédez à http://localhost:9000
2. Connectez-vous avec `admin` / `admin`
3. Changez le mot de passe (fortement recommandé)
4. Créez un nouveau projet:
   - Project Key: `consumesafe`
   - Project Name: `ConsumeSafe`
5. Générez un token d'authentification:
   - Allez dans Account Settings (haut à droite)
   - Security → Tokens
   - Créez un token avec une durée d'expiration appropriée
   - Notez le token (vous en aurez besoin pour Jenkins)

### Intégration Jenkins

1. Récupérez le token SonarQube (voir ci-dessus)
2. Dans Jenkins:
   ```
   Manage Jenkins → Credentials → System → Global credentials
   ```
3. Créez une nouvelle credential de type "Secret text"
   - ID: sonarqube-token
   - Secret: [le token généré ci-dessus]
4. Dans la configuration Jenkinsfile:
   ```groovy
   environment {
       SONAR_TOKEN = credentials('sonarqube-token')
       SONAR_HOST_URL = 'http://sonarqube:9000'
   }
   ```

## Commandes Utiles

### Arrêter les services

```bash
# Arrêter sans supprimer les volumes
docker-compose down

# Avec le fichier complet
docker-compose -f docker-compose-full.yml down
```

### Supprimer tout (y compris les données)

```bash
# Supprimer containers, networks, volumes
docker-compose down -v

# Avec le fichier complet
docker-compose -f docker-compose-full.yml down -v
```

### Reconstruire l'image ConsumeSafe

```bash
# Reconstruire l'image Docker
docker-compose build

# Reconstruire et redémarrer
docker-compose up -d --build

# Avec le fichier complet
docker-compose -f docker-compose-full.yml up -d --build
```

### Voir les ressources utilisées

```bash
# Afficher l'utilisation CPU/Memory
docker stats

# Pour un conteneur spécifique
docker stats consumesafe-app
```

### Nettoyer les images inutilisées

```bash
# Nettoyer les images dangling
docker image prune -f

# Nettoyer complètement
docker system prune -a
```

## Health Checks

Le docker-compose.yml inclut des health checks pour chaque service:

```bash
# Voir le statut des health checks
docker-compose ps

# Exemple de sortie:
# NAME                 STATUS
# consumesafe-mysql    Up 2 minutes (healthy)
# consumesafe-app      Up 1 minute (healthy)
# consumesafe-sonarqube Up 1 minute (healthy)
```

## Limites de Ressources

Les services sont configurés avec des limites de ressources:

### MySQL
- **CPU Limit**: 1.0 core
- **Memory Limit**: 1024M

### App
- **CPU Limit**: 2.0 cores
- **Memory Limit**: 2048M
- **CPU Reservation**: 1.0 core
- **Memory Reservation**: 1024M

### SonarQube
- **CPU Limit**: 2.0 cores
- **Memory Limit**: 2048M

### PostgreSQL
- **CPU Limit**: 1.0 core
- **Memory Limit**: 512M

Ajustez ces valeurs selon vos ressources matérielles.

## Variables d'Environnement Personnalisées

### Pour ConsumeSafe

Créez un fichier `.env` à la racine du projet:

```env
# MySQL
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_PASSWORD=consumesafe123

# SonarQube
SONAR_DB_PASSWORD=sonarqube

# Application
SPRING_PROFILES_ACTIVE=prod
```

Puis utilisez:
```bash
docker-compose --env-file .env up -d
```

## Accès aux Bases de Données

### MySQL (depuis le host)

```bash
# Connection string
mysql -h 127.0.0.1 -P 3306 -u consumesafe -pconsumesafe123 -D consumesafe

# Ou avec Docker Exec
docker exec -it consumesafe-mysql mysql -u consumesafe -pconsumesafe123 consumesafe
```

### PostgreSQL (depuis le host)

```bash
# Connection string
psql -h 127.0.0.1 -p 5432 -U sonarqube -d sonarqube

# Ou avec Docker Exec
docker exec -it consumesafe-postgres psql -U sonarqube -d sonarqube
```

## Troubleshooting

### L'application ne peut pas se connecter à MySQL

```bash
# 1. Vérifier que MySQL est healthy
docker-compose ps mysql

# 2. Vérifier la connectivité
docker exec consumesafe-app ping mysql

# 3. Vérifier les logs MySQL
docker-compose logs mysql

# 4. Vérifier les logs de l'application
docker-compose logs app
```

### SonarQube ne démarre pas

```bash
# 1. Vérifier PostgreSQL
docker-compose -f docker-compose-full.yml ps postgres

# 2. Voir les logs SonarQube
docker-compose -f docker-compose-full.yml logs sonarqube

# 3. Vérifier l'espace disque
docker system df

# 4. Augmenter la mémoire Docker si nécessaire
# Sur Docker Desktop: Settings → Resources → Memory
```

### Erreur de permission sur les volumes

```bash
# Sur Linux, changer les propriétés:
sudo chown -R 1000:1000 mysql_data/
sudo chown -R 1000:1000 postgres_data/
sudo chown -R 1000:1000 sonarqube_data/
```

### Port déjà utilisé

```bash
# Trouver quel processus utilise le port
# Linux/Mac
lsof -i :8083
lsof -i :3306
lsof -i :9000

# Windows PowerShell
Get-Process -Id (Get-NetTCPConnection -LocalPort 8083).OwningProcess

# Solution: Changer le port dans docker-compose.yml
# Exemple: "8084:8083" au lieu de "8083:8083"
```

## Sauvegarde et Restauration

### Sauvegarde des données MySQL

```bash
# Dump complet
docker exec consumesafe-mysql mysqldump -u consumesafe -pconsumesafe123 consumesafe > backup.sql

# Avec gzip
docker exec consumesafe-mysql mysqldump -u consumesafe -pconsumesafe123 consumesafe | gzip > backup.sql.gz
```

### Restauration des données MySQL

```bash
# Depuis un dump
docker exec -i consumesafe-mysql mysql -u consumesafe -pconsumesafe123 consumesafe < backup.sql

# Depuis un gzip
gunzip < backup.sql.gz | docker exec -i consumesafe-mysql mysql -u consumesafe -pconsumesafe123 consumesafe
```

### Sauvegarde des volumes

```bash
# Créer une archive des volumes
docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz -C /data .

# Restaurer depuis l'archive
docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql_backup.tar.gz -C /data
```

## Logs et Monitoring

### Voir les logs en temps réel

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f app
docker-compose logs -f mysql

# Dernières 100 lignes
docker-compose logs --tail=100 app
```

### Exporter les logs

```bash
# Exporter les logs de l'app
docker logs consumesafe-app > app.log 2>&1

# Exporter avec timestamps
docker logs --timestamps consumesafe-app > app_with_timestamps.log 2>&1
```

## Mise à Jour

### Mettre à jour ConsumeSafe

```bash
# 1. Reconstruire l'image
docker-compose build app

# 2. Redémarrer le service
docker-compose up -d app

# 3. Vérifier les logs
docker-compose logs -f app
```

### Mettre à jour les images de base

```bash
# 1. Pull les images les plus récentes
docker-compose pull

# 2. Reconstruire
docker-compose build

# 3. Redémarrer
docker-compose up -d
```

## Production Considerations

### Pour un déploiement en production:

1. **Secrets Management**
   ```bash
   # Utiliser Docker Secrets au lieu de variables d'environnement
   # Ou utiliser un gestionnaire de secrets externe (Vault, etc.)
   ```

2. **Reverse Proxy**
   ```yaml
   # Ajouter Nginx ou Caddy devant ConsumeSafe
   nginx:
     image: nginx:alpine
     ports:
       - "80:80"
       - "443:443"
   ```

3. **Backup Automatisé**
   ```bash
   # Ajouter des cronjobs pour les sauvegardes régulières
   0 2 * * * docker exec consumesafe-mysql mysqldump ... > backup.sql
   ```

4. **Monitoring**
   ```yaml
   # Ajouter Prometheus + Grafana pour le monitoring
   prometheus:
     image: prom/prometheus
   grafana:
     image: grafana/grafana
   ```

5. **Logging Centralisé**
   ```yaml
   # Ajouter ELK Stack ou Loki
   loki:
     image: grafana/loki
   ```

## Support

Pour plus d'informations:
- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- SonarQube: https://docs.sonarqube.org/
- MySQL: https://dev.mysql.com/doc/
- PostgreSQL: https://www.postgresql.org/docs/
