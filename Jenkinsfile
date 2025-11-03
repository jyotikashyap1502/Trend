pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = "${env.DOCKERHUB_CREDENTIALS_USR}"
        DOCKERHUB_REPO = "${env.DOCKERHUB_USERNAME}/trend-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_REGION = 'ap-south-1'
        EKS_CLUSTER_NAME = 'trend-cluster'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/jyotikashyap1502/Trend.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build --platform linux/amd64 -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                        docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                    """
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                        docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_REPO}:latest
                        docker logout
                    """
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        kubectl set image deployment/trend-app trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} --record
                        kubectl rollout status deployment/trend-app
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
