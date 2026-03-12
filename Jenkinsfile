pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Build started from GitHub webhook"
            }
        }

        stage('Test') {
            steps {
                echo "Running tests"
            }
        }

        stage('Deploy') {
            steps {
                echo "Deployment stage"
            }
        }
    }
}
