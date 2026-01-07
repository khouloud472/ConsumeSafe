# ConsumeSafe Deployment Pipeline Script (Windows)
# Cette script simule les étapes du Jenkinsfile pour développement local

param(
    [string]$Stage = "all",
    [switch]$SkipTests = $false,
    [switch]$SkipDocker = $false
)

$ErrorActionPreference = "Stop"
$APP_NAME = "consumesafe"
$DOCKER_IMAGE = "consumesafe:latest"
$BUILD_NUMBER = Get-Date -Format "yyyyMMddHHmmss"

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    ConsumeSafe Build & Deployment        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan

# Stage 1: Checkout
function Stage-Checkout {
    Write-Host "`n[STAGE] Checkout" -ForegroundColor Yellow
    Write-Host "Repository: ConsumeSafe" -ForegroundColor Green
    Write-Host "Branch: main" -ForegroundColor Green
}

# Stage 2: Build Maven
function Stage-Build {
    Write-Host "`n[STAGE] Build Maven" -ForegroundColor Yellow
    
    if ($SkipTests) {
        Write-Host "Building without tests..." -ForegroundColor Green
        mvn clean package -DskipTests
    } else {
        Write-Host "Building with tests..." -ForegroundColor Green
        mvn clean package
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Build successful!" -ForegroundColor Green
}

# Stage 3: Tests
function Stage-Tests {
    if ($SkipTests) {
        Write-Host "`n[STAGE] Tests - SKIPPED" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n[STAGE] Tests" -ForegroundColor Yellow
    mvn test
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Tests successful!" -ForegroundColor Green
}

# Stage 4: OWASP Dependency Check
function Stage-OWASP {
    Write-Host "`n[STAGE] Dependency Scan - OWASP" -ForegroundColor Yellow
    
    Write-Host "Running OWASP Dependency Check..." -ForegroundColor Green
    mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7 -DskipProvidedScope=true
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "OWASP scan found vulnerabilities!" -ForegroundColor Red
        exit 1
    }
    Write-Host "OWASP scan passed!" -ForegroundColor Green
}

# Stage 5: Docker Build
function Stage-Docker {
    if ($SkipDocker) {
        Write-Host "`n[STAGE] Docker Build - SKIPPED" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n[STAGE] Build Docker Image" -ForegroundColor Yellow
    
    docker build -t $DOCKER_IMAGE .
    docker tag $DOCKER_IMAGE "$($DOCKER_IMAGE):$BUILD_NUMBER"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker build failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Docker image built successfully!" -ForegroundColor Green
}

# Stage 6: Docker Compose Deploy
function Stage-Deploy {
    if ($SkipDocker) {
        Write-Host "`n[STAGE] Deploy - SKIPPED" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n[STAGE] Deploy with Docker Compose" -ForegroundColor Yellow
    
    docker-compose down -v
    docker-compose up -d --build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Deployment failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Waiting for services to start..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    
    Write-Host "`n[SUCCESS] Application deployed!" -ForegroundColor Green
    Write-Host "Access the application at: http://localhost:8083" -ForegroundColor Cyan
}

# Main execution
try {
    Stage-Checkout
    
    if ($Stage -eq "all" -or $Stage -eq "build") {
        Stage-Build
    }
    
    if ($Stage -eq "all" -or $Stage -eq "test") {
        Stage-Tests
    }
    
    if ($Stage -eq "all" -or $Stage -eq "scan") {
        Stage-OWASP
    }
    
    if ($Stage -eq "all" -or $Stage -eq "docker") {
        Stage-Docker
        Stage-Deploy
    }
    
    Write-Host "`n╔════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   Pipeline Execution Successful!           ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
}
catch {
    Write-Host "`n╔════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   Pipeline Execution Failed!               ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
