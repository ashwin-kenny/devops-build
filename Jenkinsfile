pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Image Name') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        env.IMAGE_NAME = "ashwkenny/react-app-dev:${IMAGE_TAG}"
                    } else if (env.BRANCH_NAME == 'master') {
                        env.IMAGE_NAME = "ashwkenny/react-app-prod:${IMAGE_TAG}"
                    } else {
                        error "❌ Deployment not allowed for branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            environment {
                DOCKER_CREDS = credentials('dockerhub-creds')
            }
            steps {
                sh '''
                  export DOCKER_USERNAME=$DOCKER_CREDS_USR
                  export DOCKER_PASSWORD=$DOCKER_CREDS_PSW

                  chmod +x build.sh
                  ./build.sh $IMAGE_NAME
                '''
            }
        }

        stage('Deploy to EC2') {
            environment {
                DOCKER_CREDS = credentials('dockerhub-creds')
            }
            steps {
                sshagent(credentials: ['buildserver-pem']) {
                    sh '''
                      export DOCKER_USERNAME=$DOCKER_CREDS_USR
                      export DOCKER_PASSWORD=$DOCKER_CREDS_PSW

                      chmod +x deploy.sh
                      ./deploy.sh $IMAGE_NAME
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ ${env.BRANCH_NAME} deployed successfully → ${IMAGE_NAME}"
        }
        failure {
            echo "❌ Pipeline failed for branch ${env.BRANCH_NAME}"
        }
    }
}

