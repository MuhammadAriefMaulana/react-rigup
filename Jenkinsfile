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
        //KUBE_CLUSTER = 'mariefm'
        //KUBE_ZONE = 'us-west2-a'
        // PROJECT_ID = 'group7-322208'

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
        stage('Terraform Plan') {
            steps {
                    script {
                        dir('./terraform') {
                            sh '''
                            mkdir -p creds
                            echo $KEY_TEXT | base64 -d > ./creds/serviceaccount.json
                            terraform init -force-copy || exit 1
                            terraform plan -out my.tfplan || exit 1
                            '''
                            // env.KUBE_CLUSTER = sh (
                            //     script: 'cat ./creds/kube_cluster.txt',
                            //     returnStdout: true
                            // )
                            // env.KUBE_ZONE = sh (
                            //     script: 'cat ./creds/kube_zone.txt',
                            //     returnStdout: true
                            // )
                            // env.PROJECT_ID = sh (
                            //     script: 'cat ./creds/project_id.txt',
                            //     returnStdout: true
                            // )
                        }                        
                    }
                    input message: "Continue to Terraform Apply?"
                    // echo "KUBE_CLUSTER= ${KUBE_CLUSTER}"
                    // echo "KUBE_ZONE= ${KUBE_ZONE}"
                    // echo "PROJECT_ID= ${PROJECT_ID}"                 
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('./terraform') {
                        sh '''                            
                        terraform apply -input=false -auto-approve
                        terraform output kube_cluster | sed 's/"//g' > ./creds/kube_cluster.txt
                        terraform output kube_zone | sed 's/"//g' > ./creds/kube_zone.txt
                        terraform output project_id | sed 's/"//g' > ./creds/project_id.txt
                        '''
                        env.KUBE_CLUSTER = sh (
                            script: 'cat ./creds/kube_cluster.txt',
                            returnStdout: true
                        )
                        env.KUBE_ZONE = sh (
                            script: 'cat ./creds/kube_zone.txt',
                            returnStdout: true
                        )
                        env.PROJECT_ID = sh (
                            script: 'cat ./creds/project_id.txt',
                            returnStdout: true
                        )
                    }                        
                }
                input message: "Continue to Kubectl Apply?"
            }
        }
        // stage 9
        stage('Apply Kubernetes File') {
            steps {
                withCredentials([file(credentialsId: KEY_FILE, variable: 'GC_KEY')]) {
                    sh 'gcloud auth activate-service-account --key-file=${GC_KEY}'
                    sh 'gcloud container clusters get-credentials ${KUBE_CLUSTER} --zone ${KUBE_ZONE} --project ${PROJECT_ID}'
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }
}

def getDockerTag(){
    def tag = sh script: "git rev-parse HEAD", returnStdout: true
    return tag
}