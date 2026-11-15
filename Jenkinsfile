pipeline {
    agent any
    environment {
        IMAGE_NAME = "healthcare-portal:secure"
        KUBE = "--kubeconfig=/var/jenkins_home/.kube/config --insecure-skip-tls-verify"
    }
    stages {
        stage('1. Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/divakar-2005/healthcare-devsecops-demo.git'
            }
        }
        stage('2. Secret & PHI Leak Scan') {
            steps {
                script {
                    // Fail build if hardcoded API keys, passwords, or private keys are found
                    def leaks = sh(script: "grep -rnE '(API_KEY|PASSWORD|SECRET_KEY|BEGIN RSA PRIVATE KEY)' . --exclude=Jenkinsfile || true", returnStdout: true).trim()
                    if (leaks) {
                        error("SECURITY GATE FAILED: Hardcoded secret detected!\n${leaks}")
                    }
                    echo "Secret Scan Passed: No hardcoded credentials or PHI keys found."
                }
            }
        }
        stage('3. Build Hardened Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }
        stage('4. Trivy Vulnerability Scan') {
            steps {
                // Scans the Docker image for CRITICAL OS/library vulnerabilities; blocks build if found
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity CRITICAL --exit-code 1 --no-progress ${IMAGE_NAME}"
            }
        }
        stage('5. Load & Deploy to Kubernetes') {
            steps {
                sh "docker save ${IMAGE_NAME} -o /tmp/hc.tar && docker cp /tmp/hc.tar desktop-control-plane:/root/hc.tar && docker exec desktop-control-plane ctr --namespace=k8s.io images import /root/hc.tar"
                sh "kubectl ${KUBE} apply -f healthcare-deployment.yaml"
                sh "kubectl ${KUBE} rollout restart deployment/healthcare-portal"
                sh "kubectl ${KUBE} rollout status deployment/healthcare-portal"
            }
        }
    }
}
