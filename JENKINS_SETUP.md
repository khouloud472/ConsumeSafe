# Jenkins Pipeline Configuration Guide for ConsumeSafe

## Prerequisites Installation

### 1. Jenkins Server Setup
```bash
# Install Jenkins (if not already installed)
# Download from https://www.jenkins.io/download/
```

### 2. Required Jenkins Plugins
Install the following plugins in Jenkins:
- **Pipeline** - For declarative pipeline support
- **Git** - For Git integration
- **SonarQube Scanner** - For SonarQube integration
- **OWASP Dependency-Check** - For security scanning
- **Docker Pipeline** - For Docker integration
- **CloudBees Docker Build and Publish** - For Docker operations

### 3. Configure Jenkins Tools

#### JDK 21 Configuration
Navigate to `Manage Jenkins` → `Tools` → `JDK` and add:
- **Name**: `JDK21`
- **JAVA_HOME**: Path to your JDK 21 installation
  - Windows: `C:\Program Files\Java\jdk-21` or similar
  - Linux: `/usr/lib/jvm/java-21-openjdk`

#### Maven Configuration
Navigate to `Manage Jenkins` → `Tools` → `Maven` and add:
- **Name**: `Maven`
- **MAVEN_HOME**: Path to your Maven installation
  - Windows: `C:\apache-maven-3.9.x`
  - Linux: `/opt/maven`

### 4. Configure Jenkins Credentials

#### Git Credentials
1. Go to `Manage Jenkins` → `Manage Credentials`
2. Add credentials for GitHub repository
3. Create a Personal Access Token on GitHub
4. Add it to Jenkins as "GitHub" credentials

#### SonarQube Token
1. Generate a token in SonarQube (`Administration` → `Security` → `Tokens`)
2. Add it to Jenkins credentials as "SonarQube" token

#### Docker Registry (if using)
Add Docker Hub or private registry credentials

### 5. Configure SonarQube Server

#### In Jenkins
1. Go to `Manage Jenkins` → `Configure System`
2. Find `SonarQube servers` section
3. Add SonarQube server:
   - **Name**: `SonarQube`
   - **Server URL**: `http://localhost:9000`
   - **Server authentication token**: Use the token created above

#### SonarQube Configuration
In SonarQube, create a project with key: `consumesafe`

### 6. Required External Tools

#### Docker (for container building)
- **Windows**: Docker Desktop
- **Linux**: `sudo apt-get install docker.io`

#### Docker Compose
```bash
# Install Docker Compose
# Windows: Included in Docker Desktop
# Linux: sudo apt-get install docker-compose
```

#### Gitleaks (for secret scanning)
```bash
# Install Gitleaks
# macOS: brew install gitleaks
# Windows: Download from https://github.com/gitleaks/gitleaks/releases
# Linux: Download or use package manager
```

#### Trivy (for container scanning)
```bash
# Install Trivy
# Windows/macOS: brew install trivy
# Linux: Download from https://github.com/aquasecurity/trivy/releases
```

### 7. Configure Pipeline Environment

Create or update your Jenkinsfile with proper tool configurations. The pipeline expects:
- JDK 21 available as 'JDK21'
- Maven available as 'Maven'
- Docker available on agent
- SonarQube server configured

### 8. Webhook Configuration (Optional but Recommended)

In your GitHub repository:
1. Go to Settings → Webhooks
2. Add webhook: `http://your-jenkins-url/github-webhook/`
3. Select "Push events" and "Pull requests"

## Running the Pipeline

### Manual Trigger
1. Go to Jenkins dashboard
2. Click on `ConsumeSafe` job
3. Click `Build Now`

### Automatic Trigger
Push to the `main` branch will automatically trigger the pipeline

## Troubleshooting

### Common Issues

#### Build Failures
- Check Java version: `java -version` should show Java 21
- Check Maven: `mvn -version`
- Check dependencies in pom.xml are correct

#### Test Failures
- Run tests locally: `mvn test`
- Check test configurations in `application-test.properties`
- Ensure H2 database is properly configured for tests

#### Docker Issues
- Ensure Docker daemon is running
- Check Docker permissions: `docker ps`
- For Linux, may need sudo or add user to docker group

#### SonarQube Issues
- Verify SonarQube server is running: `http://localhost:9000`
- Check token validity
- Verify project key matches in pom.xml

## Performance Optimization

### Maven
- Use offline mode for faster builds: `mvn -o clean package`
- Cache dependencies properly

### Docker
- Use multi-stage builds (already implemented)
- Cache layers properly
- Use smaller base images

### Jenkins
- Use pipeline caching
- Configure executor pools
- Use distributed builds if needed

## Security Best Practices

1. **Secrets Management**
   - Never commit secrets to Git
   - Use Jenkins credentials store
   - Use Gitleaks to detect secrets

2. **Dependency Management**
   - Regularly update dependencies
   - Use OWASP Dependency Check
   - Monitor CVEs

3. **Container Security**
   - Scan images with Trivy
   - Use non-root users in containers
   - Keep base images updated

4. **Code Quality**
   - Use SonarQube for code analysis
   - Set quality gates
   - Review SAST findings

## Monitoring and Reporting

### Build Artifacts
- JAR file: `target/consumesafe-1.0.0.jar`
- Docker image: `consumesafe:latest`
- Reports: Available in Jenkins workspace

### Logs
- Build logs: Available in Jenkins UI
- Application logs: Check Docker container logs
- SonarQube dashboard: Detailed code analysis

## Maintenance

- Review and update Jenkins plugins regularly
- Monitor disk space on Jenkins agents
- Archive build artifacts regularly
- Clean up old builds and artifacts

