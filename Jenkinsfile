pipeline {
    agent any
    environment {
        registryFrontEnd = "muhammadariefmaulana/rigup_frontend"
        registryBackEnd = "muhammadariefmaulana/rigup_backend"
        registryDatabase = "muhammadariefmaulana/rigup_database"
        registryCredential = 'dockerhub'  //dockerhub --> add credential di jenkins terlebih dahulu dengan ID dockerhub
        SERVICE_ACCOUNT = 'devops-telkomsel-7-new@group7-322208.iam.gserviceaccount.com'
        KEY_TEXT = credentials('devops-telkomsel-7-new-SA-text') //add di credential
        KEY_FILE = 'devops-telkomsel-7-new-SA' //add di credential
        KUBE_CLUSTER = 'mariefm-2'
        KUBE_ZONE = 'us-west2-a'
        PROJECT_ID = 'group7-322208'
        NAMESPACE = 'mariefm'
    }

    stages {
        stage('Check Jenkins Workspace') {
            when {
                anyOf {
                    branch "main"
                    branch "mariefm"
                    changeRequest()
                }
            }
            steps {
                sh "chmod +x -R ${env.WORKSPACE}"
                // sh 'sudo groupadd docker'
                // sh 'sudo usermod -aG docker $USER'
                sh './jenkins/scripts/test.sh'
            }
        }
        
        stage('Build Docker Images') {
            when { changeset "**/Dockerfile" }
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
        
        stage('Test Docker Images') {
            when { changeset "**/Dockerfile" }
            steps {
                sh 'docker run -d --rm --name frontend -p 8081:80 $registryFrontEnd'
                sh 'docker run -d --rm --name backend -p 2000:2000 $registryBackEnd'
                sh 'docker run -d --rm --name database -p 3306:3306 $registryDatabase'
                // input message: "Done Test Docker Image. Continue?"
            }
        }

        stage('Clean Up Docker Test') {
            when { changeset "**/Dockerfile" }
            steps {
                sh 'docker stop frontend || true && docker stop backend || true && docker stop database || true'
            }
        }

        stage('Push Docker Images to Registry') {
            when { 
                allOf {
                    branch "main"
                    changeset "**/Dockerfile"
                }
            }
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

        stage('Clean Up Images') {
            when { 
                allOf {
                    branch "main"
                    changeset "**/Dockerfile"
                }
            }
            steps {
                sh 'docker rmi $registryFrontEnd && docker rmi $registryBackEnd && docker rmi $registryDatabase'
            }
        }
        
        stage('Terraform Init & Plan') {
            when {
                anyOf {
                    changeset "**/*.tf"
                }
            }
            steps {
                script {
                    dir('./terraform') {
                        sh '''
                        mkdir -p creds
                        echo $KEY_TEXT | base64 -d > ./creds/serviceaccount.json
                        terraform init -force-copy || exit 1
                        terraform plan -out my.tfplan || exit 1
                        '''
                    }                        
                }
                input message: "Continue to Terraform Apply?"               
            }
        }

        // stage('Terraform Destroy') {
        //     steps {
        //         script {
        //             dir('./terraform') {
        //                 sh 'terraform destroy'
        //             }       
        //         }
        //     }
        // }

        stage('Terraform Apply') {
            when { 
                allOf {
                    branch "main"
                    changeset "**/*.tf"
                }
            }
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
                        echo "KUBE_CLUSTER= ${KUBE_CLUSTER}"
                        echo "KUBE_ZONE= ${KUBE_ZONE}"
                        echo "PROJECT_ID= ${PROJECT_ID}"  
                    }                        
                }
                // input message: "Continue to Kubectl Apply?"
            }
        }

        stage('Apply Kubernetes File') {
            when {
                allOf {
                    branch "main"
                    changeset "kubernetes/*.yaml"
                }
            }
            steps {
                withCredentials([file(credentialsId: KEY_FILE, variable: 'GC_KEY')]) {
                    //authentication
                    sh 'gcloud auth activate-service-account --key-file=${GC_KEY}'
                    sh 'gcloud container clusters get-credentials ${KUBE_CLUSTER} --zone ${KUBE_ZONE} --project ${PROJECT_ID}'
                    sh 'cat ~/.kube/config'
                    //generate a self-signed certificate and private key with:
                    sh '''
                    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ingress.key -out ingress.cert -subj "/CN=devops7.telkomsel.com/O=devops7.telkomsel.com" || true
                    kubectl create secret tls ingress-cert --key ingress.key --cert ingress.cert -n $NAMESPACE || true
                    '''
                    //apply kubernetes
                    // sh 'kubectl get pod'
                    sh 'kubectl apply -f kubernetes/deployment.yaml'
                    //get all resource
                    sh 'kubectl get all -n $NAMESPACE'
                }
            }
        }
    }
}