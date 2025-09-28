pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = "kiran1703/swe645hw2"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG_FILE = credentials('kubeconfig-prod')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/kiranannadatha8/swe645hw1.git'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    sh """
                      echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                      docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                      docker push ${IMAGE_NAME}:${IMAGE_TAG}
                      docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-prod', variable: 'KUBECONFIG')]) {
                    sh """
                      kubectl --kubeconfig=$KUBECONFIG apply -f deployment.yaml
                      kubectl --kubeconfig=$KUBECONFIG apply -f service.yaml
                      kubectl --kubeconfig=$KUBECONFIG set image deployment/swe645hw2 swe645hw2=${IMAGE_NAME}:${IMAGE_TAG} --record
                      kubectl --kubeconfig=$KUBECONFIG rollout status deployment/swe645hw2 --timeout=120s
                    """
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
