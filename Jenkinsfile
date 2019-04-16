pipeline {
    agent {
        label 'u32-linux-bld09.cisco.com' 
    }
    stages {
        stage('SCM'){
            steps{
                // echo 'SCM checkout'
                git credentialsId: '<userid>', url: '<bitbucket url>'
            }
        }
        stage('Pre-requisets step'){
            steps{
                script {
                    echo "This is generally the step to prepare the environment to build the product. Eg: We set build label here."
                    currentBuild.displayName=sh returnStdout: true, script: 'cat version.txt '
                    
                }
            }
        }
        stage('Sonar'){
            steps{
                echo 'Run sonar static analysis.'
            }
        }
        stage('Build'){
            steps{
                echo 'Run Product Build.'
                script {
                    status=sh returnStatus: true, script: '<path to script>/cinemo_bldscript.sh <args>'
                    
                }
            }
        }
        stage('UT/Coverage'){
            steps{
                echo 'Run ut/coverage tests.'
            }
        }
        stage('Run Tests') {
            parallel {
                stage('Test On node1') {
                    agent {
                        label "u32-linux-bld07.cisco.com"
                    }
                    steps {
                        sh "echo run tests"
                    }
                    post {
                        always {
                            sh "echo update test results"
                        }
                    }
                }
                stage('Test On node2') {
                    agent {
                        label "u32-linux-bld08.cisco.com"
                    }
                    steps {
                        sh "echo run-tests "
                    }
                    post {
                        always {
                            sh "echo results update "
                        }
                    }
                }
            }
        }
        stage('Certify the build'){
            steps{
                echo 'build qualification.'
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
