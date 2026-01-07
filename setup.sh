#!/bin/bash
# Installation script for Jenkins and dependencies on Linux

set -e

echo "================================"
echo "Jenkins Setup Script for ConsumeSafe"
echo "================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Java Installation
echo "Checking Java 21 installation..."
if ! command_exists java || ! java -version 2>&1 | grep -q "21"; then
    echo "Installing Java 21..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
            sudo apt-get update
            sudo apt-get install -y openjdk-21-jdk
        elif [ "$ID" = "centos" ] || [ "$ID" = "rhel" ]; then
            sudo yum install -y java-21-openjdk java-21-openjdk-devel
        fi
    fi
fi

# 2. Maven Installation
echo "Checking Maven installation..."
if ! command_exists mvn; then
    echo "Installing Maven..."
    cd /opt
    sudo wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
    sudo tar xzf apache-maven-3.9.6-bin.tar.gz
    sudo ln -s apache-maven-3.9.6 maven
    echo "export PATH=/opt/maven/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh
fi

# 3. Docker Installation
echo "Checking Docker installation..."
if ! command_exists docker; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo groupadd docker || true
    sudo usermod -aG docker $USER
fi

# 4. Docker Compose Installation
echo "Checking Docker Compose installation..."
if ! command_exists docker-compose; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 5. Gitleaks Installation
echo "Checking Gitleaks installation..."
if ! command_exists gitleaks; then
    echo "Installing Gitleaks..."
    sudo curl -L https://github.com/gitleaks/gitleaks/releases/download/v8.18.1/gitleaks-linux-x64 -o /usr/local/bin/gitleaks
    sudo chmod +x /usr/local/bin/gitleaks
fi

# 6. Trivy Installation
echo "Checking Trivy installation..."
if ! command_exists trivy; then
    echo "Installing Trivy..."
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install -y trivy
fi

# 7. Git Installation
echo "Checking Git installation..."
if ! command_exists git; then
    echo "Installing Git..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
            sudo apt-get install -y git
        elif [ "$ID" = "centos" ] || [ "$ID" = "rhel" ]; then
            sudo yum install -y git
        fi
    fi
fi

echo ""
echo "================================"
echo "Installation Complete!"
echo "================================"
echo ""
echo "Installed versions:"
java -version 2>&1 | head -1
mvn -version | head -1
docker --version
docker-compose --version
gitleaks version 2>/dev/null || echo "Gitleaks: installed"
trivy version 2>/dev/null || echo "Trivy: installed"

echo ""
echo "Next steps:"
echo "1. Install SonarQube server (Docker or standalone)"
echo "2. Create Jenkins pipeline from Jenkinsfile"
echo "3. Configure Jenkins tools (JDK21, Maven)"
echo "4. Add credentials to Jenkins"
echo "5. Run the pipeline"
