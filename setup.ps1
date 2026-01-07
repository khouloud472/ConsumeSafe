# Windows Setup Script for Jenkins and ConsumeSafe Dependencies
# Run as Administrator

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Jenkins Setup Script for ConsumeSafe (Windows)" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit 1
}

# Function to check if command exists
function Test-CommandExists {
    param($command)
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# 1. Check Java 21
Write-Host "Checking Java 21 installation..." -ForegroundColor Yellow
if (Test-CommandExists java) {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "Java found: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "Java 21 not found. Please install from: https://adoptium.net/" -ForegroundColor Red
    Write-Host "After installation, add Java to PATH environment variable" -ForegroundColor Yellow
}

# 2. Check Maven
Write-Host "Checking Maven installation..." -ForegroundColor Yellow
if (Test-CommandExists mvn) {
    $mvnVersion = mvn -version | Select-String "Apache Maven"
    Write-Host "Maven found: $mvnVersion" -ForegroundColor Green
} else {
    Write-Host "Maven not found. Please install from: https://maven.apache.org/download.cgi" -ForegroundColor Red
    Write-Host "After installation, add Maven to PATH environment variable" -ForegroundColor Yellow
}

# 3. Check Git
Write-Host "Checking Git installation..." -ForegroundColor Yellow
if (Test-CommandExists git) {
    $gitVersion = git --version
    Write-Host "Git found: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "Git not found. Please install from: https://git-scm.com/" -ForegroundColor Red
}

# 4. Check Docker
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
if (Test-CommandExists docker) {
    $dockerVersion = docker --version
    Write-Host "Docker found: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "Docker not found. Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Red
}

# 5. Check Docker Compose
Write-Host "Checking Docker Compose installation..." -ForegroundColor Yellow
if (Test-CommandExists docker-compose) {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose found: $composeVersion" -ForegroundColor Green
} else {
    Write-Host "Docker Compose not found. Usually included with Docker Desktop" -ForegroundColor Yellow
}

# 6. Check Gitleaks
Write-Host "Checking Gitleaks installation..." -ForegroundColor Yellow
if (Test-CommandExists gitleaks) {
    $gitleaksVersion = gitleaks version
    Write-Host "Gitleaks found: $gitleaksVersion" -ForegroundColor Green
} else {
    Write-Host "Gitleaks not found. Download from: https://github.com/gitleaks/gitleaks/releases" -ForegroundColor Yellow
}

# 7. Check Trivy
Write-Host "Checking Trivy installation..." -ForegroundColor Yellow
if (Test-CommandExists trivy) {
    $trivyVersion = trivy version
    Write-Host "Trivy found" -ForegroundColor Green
} else {
    Write-Host "Trivy not found. Download from: https://github.com/aquasecurity/trivy/releases" -ForegroundColor Yellow
}

# Environment Variables Check
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Environment Variables Check" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine")
$env:M2_HOME = [System.Environment]::GetEnvironmentVariable("M2_HOME","Machine")
$env:MAVEN_HOME = [System.Environment]::GetEnvironmentVariable("MAVEN_HOME","Machine")

Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor $(if ($env:JAVA_HOME) { "Green" } else { "Red" })
Write-Host "M2_HOME: $env:M2_HOME" -ForegroundColor $(if ($env:M2_HOME) { "Green" } else { "Yellow" })
Write-Host "MAVEN_HOME: $env:MAVEN_HOME" -ForegroundColor $(if ($env:MAVEN_HOME) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Quick Test" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Java version:" -ForegroundColor Yellow
java -version 2>&1

Write-Host ""
Write-Host "Maven version:" -ForegroundColor Yellow
mvn -version 2>&1 | Select-Object -First 3

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Verify all tools are properly installed"
Write-Host "2. Install Jenkins from: https://www.jenkins.io/"
Write-Host "3. Install Jenkins plugins (Pipeline, Git, SonarQube, etc.)"
Write-Host "4. Configure Jenkins tools (JDK21, Maven)"
Write-Host "5. Set up SonarQube server"
Write-Host "6. Configure credentials in Jenkins"
Write-Host "7. Create new Pipeline job from the Jenkinsfile"
Write-Host ""
