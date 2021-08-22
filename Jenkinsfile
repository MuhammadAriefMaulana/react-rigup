pipeline {
    agent any
    environment {
        CI = 'true'
        DOCKER_TAG = getDockerTag()
        registryFrontEnd = "muhammadariefmaulana/rigup_frontend"
        registryBackEnd = "muhammadariefmaulana/rigup_backend"
        registryDatabase = "muhammadariefmaulana/rigup_database"
        registryCredential = 'dockerhub'  //dockerhub --> add credential di jenkins terlebih dahulu dengan ID dockerhub
        dockerImageFE = ''
        dockerImageBE = ''
        dockerImageDB = ''
        KEY_TEXT = credentials('devops-telkomsel-7-new-SA-text')
        KEY_FILE = 'devops-telkomsel-7-new-SA' //add di credential
        KUBE_CLUSTER = 'mariefm'
        KUBE_ZONE = 'us-west2-a'
        PROJECT_ID = 'group7-322208'

    }

    stages {
        /*// stage 1
        stage('Install Dependencies React Project') {
            steps {
                echo 'Start installing dependencies react project'
                sh 'npm install'
            }
        }
        // stage 2
        stage('Check Jenkins Workspace') {
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
        stage('Build Docker Images') {
            parallel {
                stage('Front End') {
                    steps {
                        dir('./rigup_frontend') {
                            script {
                                // dockerImage=docker.build("$registryBackEnd:$BUILD_NUMBER") //change
                                dockerImageFE=docker.build(registryFrontEnd)
                            }
                        }
                    }
                }
                stage('Back End') {
                    steps {
                        dir('./rigup_backend') {
                            script {
                                // dockerImage=docker.build("$registryBackEnd:$BUILD_NUMBER") //change
                                dockerImageBE=docker.build(registryBackEnd)
                            }
                        }
                    }
                }
                stage('Database') {
                    steps {
                        dir('./database') {
                            script {
                                // dockerImage=docker.build("$registryBackEnd:$BUILD_NUMBER") //change
                                dockerImageDB=docker.build(registryDatabase)
                            }
                        }
                    }
                }
            }
        }
        
        // stage 5
        stage('Test Docker Images') {
            steps {
                sh 'docker run -d --rm --name frontend -p 8081:80 $registryFrontEnd'
                sh 'docker run -d --rm --name backend -p 2000:2000 $registryBackEnd'
                sh 'docker run -d --rm --name database -p 3306:3306 $registryDatabase'
                input message: "Done Test Docker Image. Continue?"
            }
        }
        // // stage 6
        stage('Clean Up Docker Test') {
            steps {
                // sh 'docker stop muhammadariefmaulana/rigup_frontend'
                // sh 'docker stop $(docker ps -q --filter ancestor=$registryFrontEnd ) || true'
                sh 'docker stop frontend || true && docker stop backend || true && docker stop database || true'
            }
        }
        // stage 7
        stage('Push Docker Images to Registry') {
            parallel {
                stage('Front End') {
                    steps {
                        script {
                            docker.withRegistry('', registryCredential) {
                                dockerImageFE.push()
                            }
                        }
                    }
                }
                stage('Back End') {
                    steps {
                        script {
                            docker.withRegistry('', registryCredential) {
                                dockerImageBE.push()
                            }
                        }
                    }
                }
                stage('Database') {
                    steps {
                        script {
                            docker.withRegistry('', registryCredential) {
                                dockerImageDB.push()
                            }
                        }
                    }
                }
            }           
        }        
        // stage 8
        stage('Clean Up Images') {
            steps {
                sh 'docker rmi $registryFrontEnd && docker rmi $registryBackEnd && docker rmi $registryDatabase'
            }
        }
        // stage 9
        // stage('Apply Kubernetes File') {
        //     steps {
        //         sh "chmod +x changeTag.sh"
        //         sh "./changeTag.sh ${DOCKER_TAG}"
        //         withKubeConfig([credentialsId: '#kube_credential_Id#', serverUrl: '#k8s_server_url#']) {
        //             sh 'kubectl apply -f #file_deployment_kubernetes#' 
        //         }
        //     }
        // }*/

        // stage terraform
        stage('Apply Terraform') {
            steps {
                withCredentials([file(credentialsId: KEY_FILE, variable: 'GC_KEY')]) {
                    sh '''
                    cd terraform
                    mkdir -p creds
                    echo $KEY_TEXT | base64 -d > ./creds/serviceaccount.json
                    terraform init -migrate-state || exit 1
                    terraform plan || exit 1
                    '''
                }
            }
            // always {
            // KUBE_CLUSTER = google_container_cluster.devops7-cluster.name
            // KUBE_ZONE = google_container_cluster.devops7-cluster.location
            // PROJECT_ID = google_container_cluster.devops7-cluster.project
            //     sh 'echo ${KUBE_CLUSTER}'
            //     sh 'echo ${KUBE_ZONE}'
            //     sh 'echo ${PROJECT_ID}'
            // }
        }
        // stage 9
        /*stage('Apply Kubernetes File') {
            steps {
                // sh "chmod +x changeTag.sh"
                // sh "./changeTag.sh ${DOCKER_TAG}"
                // withKubeConfig([credentialsId: 'kubeconfig']) {
                //     // sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"'  
                //     // sh 'chmod u+x ./kubectl'  
                //     sh 'echo $KUBECONFIG'
                //     sh 'kubectl apply -f deployment.yaml' 
                // }
                // sh 'gcloud auth activate-service-account $SA_ACCOUNT --key-file=$KEY_FILE'
                // sh 'gcloud container clusters get-credentials $KUBE_CLUSTER --zone $KUBE_ZONE --project $PROJECT_ID'
                // sh 'echo $KUBECONFIG'
                // sh 'kubectl apply -f deployment.yaml' 

                withCredentials([file(credentialsId: KEY_FILE, variable: 'GC_KEY')]) {
                    sh 'gcloud auth activate-service-account --key-file=${GC_KEY}'
                    sh 'gcloud container clusters get-credentials ${KUBE_CLUSTER} --zone ${KUBE_ZONE} --project ${PROJECT_ID}'
                    sh 'echo $KUBECONFIG'
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }*/
    }
}

def getDockerTag(){
    def tag = sh script: "git rev-parse HEAD", returnStdout: true
    return tag
}