pipeline {
  agent any

  environment {
    APP_NAME = 'node-sample-app'
    PORT = '4444'
    SSH_CRED = 'jenkins-ssh-key'
    TARGET_USER = 'laborant'
    HOST_TARGET = 'target'
    HOST_DOCKER = 'docker'
    HOST_K8S = 'k8s'
    IMAGE_TAG = 'ttl.sh/programmerinyourarea/myapp:2h'
    REPO_URL = 'https://github.com/programmerinyourarea/devops-final-exam.git'
  }

  stages {

    stage('Deploy to Bare-Metal Target') {
  steps {
    dir('target-deploy') {
      git branch: 'target', url: "${REPO_URL}"
      sh 'npm install'
      sh 'npm test'

      sshagent([SSH_CRED]) {
        sh """
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} 'mkdir -p ~/${APP_NAME}'
          scp -o StrictHostKeyChecking=no index.js package.json ${TARGET_USER}@${HOST_TARGET}:~/${APP_NAME}
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} '
            cd ${APP_NAME} &&
            npm install
          '
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} "echo '[Unit]
Description=My Node.js App
After=network.target

[Service]
ExecStart=/usr/bin/node /home/${TARGET_USER}/${APP_NAME}/index.js
Restart=always
User=${TARGET_USER}
Environment=NODE_ENV=production
WorkingDirectory=/home/${TARGET_USER}/${APP_NAME}

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/myapp.service"
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} 'sudo systemctl daemon-reload'
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} 'sudo systemctl enable myapp.service'
          ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_TARGET} 'sudo systemctl restart myapp.service'
        """
      }
    }
  }
}


    stage('Deploy to Docker Host') {
      steps {
        dir('docker-deploy') {
          git branch: 'docker', url: "${REPO_URL}"
          sh 'npm install'
          sh 'npm test'

          sshagent([SSH_CRED]) {
            sh """
              ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_DOCKER} 'mkdir -p ~/${APP_NAME}'
              scp -o StrictHostKeyChecking=no Dockerfile index.js package.json ${TARGET_USER}@${HOST_DOCKER}:~/${APP_NAME}
              ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_DOCKER} '
                cd ${APP_NAME} &&
                docker build -t ${APP_NAME}:latest . &&
                docker rm -f ${APP_NAME} || true &&
                docker run -d -p ${PORT}:${PORT} --name ${APP_NAME} ${APP_NAME}:latest
              '
            """
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        dir('k8s-deploy') {
          git branch: 'k8s', url: "${REPO_URL}"
          sh 'npm install'
          sh 'npm test'

          sshagent([SSH_CRED]) {
            sh """
              ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_K8S} 'mkdir -p ~/${APP_NAME}'
              scp -o StrictHostKeyChecking=no Dockerfile index.js package.json ${TARGET_USER}@${HOST_K8S}:~/${APP_NAME}
              ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_K8S} '
                cd ${APP_NAME} &&
                docker build -t ${IMAGE_TAG} . &&
                docker push ${IMAGE_TAG}
              '
              scp -o StrictHostKeyChecking=no k8s-deployment.yaml ${TARGET_USER}@${HOST_K8S}:~/${APP_NAME}
              ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${HOST_K8S} '
                cd ${APP_NAME} &&
                kubectl apply -f k8s-deployment.yaml
              '
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo "All deployments completed successfully."
    }
    failure {
      echo "One or more deployments failed."
    }
  }
}
