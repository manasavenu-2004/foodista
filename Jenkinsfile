
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
                git branch: 'main',
                    url: "${SOURCE_REPO}"

                echo 'Foodista source code checkout completed'
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
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/*.min.js,**/*.min.css
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
                            echo "\$DOCKER_PASS" | docker login \
                            -u "\$DOCKER_USER" --password-stdin

                            docker build \
                            -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            -t ${DOCKER_IMAGE}:latest \
                            -f Dockerfile .

                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest

                            docker logout
                        """
                    }
                }
            }
        }

        stage('Update Manifest Repo') {
            steps {
                dir('manifest-workspace') {

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

                            sed -i -E \
                            's|(^[[:space:]]*image:[[:space:]]*).*|\\1${DOCKER_IMAGE}:${BUILD_NUMBER}|' \
                            manifests/deployment.yaml

                            git add manifests/deployment.yaml

                            if ! git diff --cached --quiet; then
                                git commit -m "Update Foodista image to ${BUILD_NUMBER}"

                                git remote set-url origin \
                                https://\${GH_USER}:\${GH_TOKEN}@github.com/manasavenu-2004/foodista.git

                                git push origin ${MANIFEST_BRANCH}
                            else
                                echo "No manifest changes to commit"
                            fi
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Foodista pipeline executed successfully!'
            echo 'Docker image pushed and manifest repository updated.'
        }

        failure {
            echo 'Pipeline failed. Please review the console logs.'
        }
    }
}
