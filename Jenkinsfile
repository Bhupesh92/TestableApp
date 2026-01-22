pipeline {
    agent any

    environment {
        LANG = "en_US.UTF-8"
        LC_ALL = "en_US.UTF-8"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                  bundle install
                  pod install
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh 'bundle exec fastlane tests'
            }
        }

        stage('Build & Upload') {
            steps {
                sh 'bundle exec fastlane beta'
            }
        }
    }

    post {
        success {
            echo "✅ CI succeeded"
        }
        failure {
            echo "❌ CI failed"
        }
    }
}

