pipeline {
    agent any

    stages {
        stage('Building') {
            steps {
                echo "Build started from GitHub webhook"
            }
        }

        stage('Testing') {
            steps {
                echo "Running tests"
            }
        }

        stage('Deploying') {
            steps {
                echo "Deployment stage"
            }
        }
    }
}
