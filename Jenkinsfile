pipeline {
    agent any

    // Define environment variables used throughout the pipeline
    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-creds' // Jenkins credentials ID containing DockerHub username and password
        IMAGE_NAME = 'spring-boot-devops-cicd'
        IMAGE_TAG = "${BUILD_NUMBER}"
        LATEST_TAG = "latest"
    }

    // Pipeline Parameters mapped precisely to requirements
    parameters {
        booleanParam(name: 'DEPLOY_DB', defaultValue: true, description: 'Deploy MySQL Database container on Worker Node')
        booleanParam(name: 'DEPLOY_APP', defaultValue: true, description: 'Deploy Spring Boot Application container on Worker Node')
        booleanParam(name: 'REMOVE_APP', defaultValue: false, description: 'Remove existing Spring Boot Application container')
        booleanParam(name: 'REMOVE_DB', defaultValue: false, description: 'Remove existing MySQL Database container')
        booleanParam(name: 'UPDATE_APP', defaultValue: false, description: 'Perform zero-downtime rolling update for the Application container')
    }

    stages {
        stage('Maven Build') {
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Maven Build (Compiling and packaging Java 21 app)"
                    echo "========================================================"
                }
                // Using Maven to clean and package the application skipping unit tests for faster deployment showcase
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Image Build') {
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Docker Image Build                              "
                    echo "========================================================"
                }
                // Build Docker image using the Dockerfile in the project root
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Docker Image Tagging') {
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Docker Image Tagging                            "
                    echo "========================================================"
                }
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Tag image for remote DockerHub repository
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:${LATEST_TAG}"
                }
            }
        }

        stage('DockerHub Push') {
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: DockerHub Push                                  "
                    echo "========================================================"
                }
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Secure login to DockerHub
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    // Push specific build tag and latest tag
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${LATEST_TAG}"
                }
            }
        }

        stage('Remove Old Images') {
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Remove Old Images (Cleaning up master node)     "
                    echo "========================================================"
                    // Remove dangling or old built images locally on master node to preserve disk space
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} || true"
                        sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:${LATEST_TAG} || true"
                    }
                }
            }
        }

        stage('Remove DB') {
            when {
                expression { return params.REMOVE_DB }
            }
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Remove DB Container via Ansible                 "
                    echo "========================================================"
                }
                // Uses system /etc/ansible/hosts inventory configured on master node connecting via SSH
                sh "ansible-playbook ansible/remove-db.yml"
            }
        }

        stage('Remove App') {
            when {
                expression { return params.REMOVE_APP }
            }
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Remove App Container via Ansible                "
                    echo "========================================================"
                }
                sh "ansible-playbook ansible/remove-app.yml"
            }
        }

        stage('Deploy Database Container') {
            when {
                expression { return params.DEPLOY_DB && !params.REMOVE_DB }
            }
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Deploy Database Container via Ansible           "
                    echo "========================================================"
                }
                sh "ansible-playbook ansible/deploy-db.yml"
            }
        }

        stage('Deploy Application Container') {
            when {
                expression { return params.DEPLOY_APP && !params.REMOVE_APP && !params.UPDATE_APP }
            }
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Deploy Application Container via Ansible        "
                    echo "========================================================"
                }
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Passing target image dynamically as an extra variable to Ansible
                    sh "ansible-playbook ansible/deploy-app.yml -e target_image=${DOCKER_USER}/${IMAGE_NAME}:${LATEST_TAG}"
                }
            }
        }

        stage('Update App') {
            when {
                expression { return params.UPDATE_APP }
            }
            steps {
                script {
                    echo "========================================================"
                    echo " Stage: Update App Container via Ansible                "
                    echo "========================================================"
                }
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "ansible-playbook ansible/update-app.yml -e target_image=${DOCKER_USER}/${IMAGE_NAME}:${LATEST_TAG}"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "========================================================"
                echo " Post Cleanup Block Executing                           "
                echo "========================================================"
                // Clean up workspace files or output execution telemetry
                cleanWs()
            }
        }
        success {
            echo "CI/CD Pipeline Completed SUCCESSFULLY! Application is active and accessible."
        }
        failure {
            echo "CI/CD Pipeline FAILED. Please check logs and troubleshooting guide."
        }
    }
}
