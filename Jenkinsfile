pipeline {
  agent any
  options { skipDefaultCheckout(true) }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Setup Python') {
      steps {
        sh '''
          python3 -m venv .venv
          . .venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt pytest flake8 bandit pip-audit
        '''
      }
    }
    stage('Lint & Test') {
      steps {
        sh '''
          . .venv/bin/activate
          flake8 .
          bandit -r . || true
          pip-audit -r requirements.txt || true
          pytest -q
        '''
      }
    }
    stage('Build Image') {
      steps { sh 'docker build -t college-erp:${BUILD_NUMBER} .' }
    }
    stage('Push Image') {
      when { branch 'main' }
      steps {
        sh '''
          docker tag college-erp:${BUILD_NUMBER} ghcr.io/${GITHUB_REPOSITORY_OWNER}/college-erp:${BUILD_NUMBER}
          echo $CR_PAT | docker login ghcr.io -u ${GITHUB_REPOSITORY_OWNER} --password-stdin
          docker push ghcr.io/${GITHUB_REPOSITORY_OWNER}/college-erp:${BUILD_NUMBER}
        '''
      }
    }
  }
}
