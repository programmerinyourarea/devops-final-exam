pipeline {
  agent any

  environment {
    APP_NAME = 'node-sample-app'
    PORT = '4444'
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

          sshagent(['jenkins-ssh-key']) {
            sh """
              ssh ${TARGET_USER}@${HOST_TARGET} 'mkdir -p ~/${APP_NAME}'
              scp index.js package.json ${TARGET_USER}@${HOST_TARGET}:~/${APP_NAME}
              ssh ${TARGET_USER}@${HOST_TARGET} '
                cd ${APP_NAME} &&
                npm install &&
                pkill -f index.js || true &&
                nohup node index.js > app.log 2>&1 &
              '
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

          sshagent(['jenkins-ssh-key']) {
            sh """
              ssh ${TARGET_USER}@${HOST_DOCKER} 'mkdir -p ~/${APP_NAME}'
              scp Dockerfile index.js package.json ${TARGET_USER}@${HOST_DOCKER}:~/${APP_NAME}
              ssh ${TARGET_USER}@${HOST_DOCKER} '
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

          sshagent(['jenkins-ssh-key']) {
            sh """
              ssh ${TARGET_USER}@${HOST_K8S} 'mkdir -p ~/${APP_NAME}'
              scp Dockerfile index.js package.json ${TARGET_USER}@${HOST_K8S}:~/${APP_NAME}
              ssh ${TARGET_USER}@${HOST_K8S} '
                cd ${APP_NAME} &&
                docker build -t ${IMAGE_TAG} . &&
                docker push ${IMAGE_TAG}
              '
              scp k8s-deployment.yaml ${TARGET_USER}@${HOST_K8S}:~/${APP_NAME}
              ssh ${TARGET_USER}@${HOST_K8S} '
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
