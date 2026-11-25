
pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'manasavenu2004/foodista'
        SONAR_SERVER_NAME     = 'sonarqube-env'
        SONAR_SCANNER_TOOL    = 'sonar-scanner'
        GIT_CREDENTIALS_ID    = 'github-cred'
        MANIFEST_REPO         = 'https://github.com/manasavenu-2004/foodista.git'
        MANIFEST_BRANCH       = 'main'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                echo 'passed'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"

                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=foodista-key \
                            -Dsonar.projectName=foodista-project \
                            -Dsonar.sources=.
                        """
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKER_CREDENTIALS_ID}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

                            docker build \
                            -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            -t ${DOCKER_IMAGE}:latest \
                            -f Dockerfile .

                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Update Manifest Repo') {
            steps {
                dir('manifest-workspace') {
                    deleteDir()

                    git branch: "${MANIFEST_BRANCH}",
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        url: "${MANIFEST_REPO}"

                    withCredentials([
                        usernamePassword(
                            credentialsId: "${GIT_CREDENTIALS_ID}",
                            usernameVariable: 'GH_USER',
                            passwordVariable: 'GH_TOKEN'
                        )
                    ]) {
                        sh """
                            git config user.name "manasavenu-2004"
                            git config user.email "manasavenu88914@gmail.com"

                            sed -i '/name: foodista/{n;s|image:.*|image: manasavenu2004/foodista:${BUILD_NUMBER}|}' manifests/deployment.yaml

                            git add manifests/deployment.yaml
                            git commit -m "Update Foodista image to ${BUILD_NUMBER}"
                            git push origin ${MANIFEST_BRANCH}
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully! Foodista manifest updated.'
        }

        failure {
            echo 'Pipeline failed. Please review the stage logs above.'
        }
    }
}
