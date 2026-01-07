pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'JDK17'
    }

    environment {
        APP_NAME = "consumesafe"
        DOCKER_IMAGE = "consumesafe:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/khouloud472/ConsumeSafe.git'
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Tests') {
            steps {
                sh 'mvn test'
            }
        }

        /* ================= DEVSECOPS ================= */

        stage('SAST - SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Dependency Scan - OWASP') {
            steps {
                sh '''
                mvn org.owasp:dependency-check-maven:check \
                -DfailBuildOnCVSS=7
                '''
            }
        }

        stage('Secrets Scan - Gitleaks') {
            steps {
                sh 'gitleaks detect --no-git'
            }
        }

        /* ============================================== */

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                sh '''
                trivy image --severity HIGH,CRITICAL \
                --exit-code 1 $DOCKER_IMAGE
                '''
            }
        }

        stage('Run Docker Compose') {
            steps {
                sh 'docker-compose down || true'
                sh 'docker-compose up -d --build'
            }
        }
    }

    post {
        success {
            echo 'Pipeline DevSecOps exécuté avec succès'
        }
        failure {
            echo 'Pipeline bloqué pour raison de sécurité'
        }
    }
}
