pipeline {
    agent any
    environment {
        CI = 'true'
        DOCKER_TAG = getDockerTag()
        registryFrontEnd = "muhammadariefmaulana/rigup_frontend"
        registryBackEnd = "muhammadariefmaulana/rigup_backend"
        registryDatabase = "muhammadariefmaulana/rigup_database"
        registryCredential = 'dockerhub'  //dockerhub --> add credential di jenkins terlebih dahulu dengan ID dockerhub
        dockerImage = ''
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
                sh "chmod +x -R ${env.WORKSPACE}"
                sh './jenkins/scripts/test.sh'
            }
        }
        // stage 3
        // stage('Build Project Front End') {
        //     steps {
        //         dir('./rigup_frontend') {
        //             sh 'npm run build'
        //         }
        //     }
        // }
        
        // stage 4
        stage('Build Docker Images - Front End') {
            steps {
                dir('./rigup_frontend') {
                    script {
                        // dockerImage=docker.build("muhammadariefmaulana/rigup_frontend:$BUILD_NUMBER") //change
                        dockerImage=docker.build(registryFrontEnd)
                    }
                }
            }
        }
        // stage 5
        stage('Test Docker Images') {
            steps {
                sh 'docker run -d --rm --name testImages -p 8081:80 muhammadariefmaulana/rigup_frontend'
                input message: "Done Test Docker Image. Continue?"
            }
        }
        // // stage 6
        stage('Clean Up Docker Test') {
            steps {
                sh 'docker stop muhammadariefmaulana/rigup_frontend'
            }
        }
        // // stage 7
        stage('Push Docker Images to Registry') {
            steps {
                script {
                    docker.withRegistry('http://registry.hub.docker.com', registryCredential) {
                        // dockerImage.push("${DOCKER_TAG}")
                        dockerImage.push()
                        // dockerImage.push("latest")
                    }
                }
            }
        }        
        // // stage 8
        stage('Clean Up Images') {
            steps {
                sh 'docker rmi $registryFrontEnd'
            }
        }
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