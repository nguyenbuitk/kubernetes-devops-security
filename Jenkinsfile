pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "buinguyen/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com"
    applicationURI = "/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'  // test webhook
            }
        }

      stage('Unit Tests - JUnit and Jacoco') {
        steps {
          sh "mvn test"
        }
      }

      stage('Mutation Tests - PIT'){
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
      }

      stage('SonarQube - SAST') {
        steps {
          withSonarQubeEnv('SonarQube') {  // lấy từ jenkins/manager/sonarqube
          sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com:9000  -Dsonar.login=sqp_b26e9b83afe448feac07ba6f881528df42180913"
          }
        // timeout(time: 2, unit: "MINUTES") {
        //   script {
        //     waitForQualityGate abortPipeline: true
        //   }
        // }
        }
      }

      // dependency plugin và trivy đều dùng cho scan vulnerability nên dùng parallel cho cả 2
      stage('Vulnerability Scan Docker') {
        steps {
          parallel(
            "Dependency Scan" : {
              sh "mvn dependency-check:check"
            },
            "Trivy Scan" : {
              sh "bash trivy-docker-image-scan.sh"
            },

            // OPA scan Dockerfile
            "OPA Conftest" : {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          )
        }

      }

      stage ('Docker Deployment') {
        steps {
          withDockerRegistry([credentialsId: "dockerhub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t buinguyen/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push buinguyen/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

      stage ('Vulnerability Scan - Kubenertes') {
        steps {
          parallel(
            "OPA Scan": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },

            "Kubesec Scan": {
              sh 'bash kubesec-scan.sh'
            },

            "Trivy scan": {
              sh 'bash trivy-k8s-scan.sh'
            }
          )
              // OPA scan kubenertes deployment and service
        }
      }

      // stage ('Kubernetes Deployment - DEV') {
      //   steps {
      //     withKubeConfig([credentialsId: 'kubeconfig']) {
      //       sh "sed -i 's#replace#buinguyen/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
      //       sh "kubectl apply -f k8s_deployment_service.yaml"
      //     }
      //   }
      // }

      stage ('Kubernetes Deployment - DEV') {
        steps {
          parallel (
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment.sh"
              }
            },

            "Rollout Status": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment-rollout-status.sh"
              }
            }
          )
          }
        }


    }

    post {
      always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      }
    }
}
