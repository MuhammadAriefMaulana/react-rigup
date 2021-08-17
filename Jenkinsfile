pipeline {
    agent any
    environment {
        CI = 'true'
        DOCKER_TAG = getDockerTag()
    }

    stages {
        // stage 1
        stage('Install Dependencies React Project') {
            steps {
                echo 'Start installing dependencies react project'
                sh 'npm install'
            }
        }
        // stage 2
        stage('Test Project') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
        // stage 3
        stage('Build Project') {
            steps {
                sh 'npm run build'
            }
        }
        // stage 4
        // stage('Build Docker Images') {
        //     steps {
        //         script {
        //             app=docker.build("muhammadariefmaulana/rigup") //change
        //         }
        //     }
        // }
        // // stage 5
        // stage('Test Docker Images') {
        //     steps {
        //         sh 'docker run -d --rm --name testImages -p 8081:80 muhammadariefmaulana/rigup'
        //     }
        // }
        // // stage 6
        // stage('Push Docker Images to Registry') {
        //     steps {
        //         sh 'docker stop muhammadariefmaulana/rigup'
        //     }
        // }
        // // stage 7
        // stage('Clean Up Docker Test') {
        //     steps {
        //         script {
        //             docker.withRegistry('http://registry.hub.docker.com', 'dockerhub') {
        //                 app.push("${DOCKER_TAG}")
        //                 app.push("latest")
        //             }
        //         }
        //     }
        // }        
        // // stage 8
        // stage('Clean Up Images') {
        //     steps {
        //         sh 'docker rmi muhammadariefmaulana/rigup'
        //     }
        // }
        // // stage 9
        // stage('Apply Kubernetes File') {
        //     steps {
        //         sh "chmod +x changeTag.sh"
        //         sh "./changeTag.sh ${DOCKER_TAG}"
        //         withKubeConfig([credentialsId: '#kube_credential_Id#', serverUrl: '#k8s_server_url#']) {
        //             sh 'kubectl apply -f #file_deployment_kubernetes#' 
        //         }
        //     }
        // }
    }
}

def getDockerTag(){
    def tag = sh script: "git rev-parse HEAD", returnStdout: true
    return tag
}