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
                withCredentials([file(credentialsId: 'kubeconfig-prod', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                      set -e
                      kubectl apply -f k8s/deployment.yaml --kubeconfig=$KUBECONFIG_FILE
                      kubectl apply -f k8s/service.yaml --kubeconfig=$KUBECONFIG_FILE
                      kubectl set image deployment/swe645hw2 swe645hw2=${IMAGE_NAME}:${IMAGE_TAG} --record --kubeconfig=$KUBECONFIG_FILE
                      kubectl rollout status deployment/swe645hw2 --timeout=120s --kubeconfig=$KUBECONFIG_FILE
                      kubectl get deployment swe645hw2 -o wide --kubeconfig=$KUBECONFIG_FILE
                      kubectl get pods -l app=swe645hw2 -o wide --kubeconfig=$KUBECONFIG_FILE
                      kubectl get svc swe645hw2 -o wide --kubeconfig=$KUBECONFIG_FILE
                    '''
                }
            }
        }
    }
}
