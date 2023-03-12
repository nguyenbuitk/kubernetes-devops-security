pipeline {
  agent any

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
        post {
          always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
          }
        }
      }

      stage('Mutation Tests - PIT'){
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post {
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
      }

      stage('SonarQube - SAST') {
        steps {
        //     withSonarQubeEnv('SonarQube') {  // lấy từ jenkins/manager/sonarqube
        //   sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com:9000 -Dsonar.login=sqp_39ba429a25731a895a91c487b0d8e6a5bb6a75b1"
        // }
        // timeout(time: 2, unit: "MINUTES") {
        //   script {
        //     waitForQualityGate abortPipeline: true
        //   }
        // }
          withSonarQubeEnv('SonarQube') {
            sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com:9000 -Dsonar.login=sqp_39ba429a25731a895a91c487b0d8e6a5bb6a75b1"
          }
          // timeout(time: 2, unit: 'MINUTES') {
          //   script {
          //   waitForQualityGate abortPipeline: true
          //   }
          // }

          maxRetry = 200
          forloop (i=0; i<maxRetry; i++){
              try {
                  timeout(time: 10, unit: 'SECONDS') {
                    script {
                    waitForQualityGate abortPipeline: true
                    }
                  }
              } catch(Exception e) {
                  if (i == maxRetry-1) {
                      throw e
                  }
              }
          }
        }
      }

      stage ('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "dockerhub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t buinguyen/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push buinguyen/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

      stage ('Kubernetes Deployment - DEV') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "sed -i 's#replace#buinguyen/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
}
