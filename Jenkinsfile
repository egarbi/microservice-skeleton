#!/usr/bin/env groovy

node('api-builds') {
  ansiColor('xterm') {
    // Mark the code checkout 'stage'....
    stage('\u2776 Checkout') {
      // Checkout code from repository and update any submodules
      checkout scm
      echo "\u2776 Pulling branch: ${env.BRANCH_NAME}"
    }

    stage('\u2777 Build') {
      //branch name from Jenkins environment variables
      echo "\u2777 Building branch: ${env.BRANCH_NAME}"
      sh 'sudo ./bin/build-image.sh'
    }

    build()
  }
}

@NonCPS
def build() {
  switch(env.BRANCH_NAME) {
    case "develop": verify(); break;
    case "master": deploy("prod"); break;
    case ~/^feature\/.*$/: verify(); break;
    case ~/^release\/.*$/: deploy("testing"); break;
    case ~/^hotfix\/.*$/: deploy("testing"); break;
    default: echo "Not building anything";
  }
}

def verify() {
  stage('\u2778 Test') {
    echo "\u2778 Bringing docker up to test the jar in ${env.BRANCH_NAME}"
    sh 'sudo ./bin/test-image.sh'
  }
}

def deploy(String env) {
  verify()
  stage('\u2779 Push') {
    echo "\u2779 Pushing image in ECR"
    sh "sudo ./bin/publish-image.sh"
  }
 
  stage('\u277A Plan Service') {
    echo "\u277A Planning ECS Service in ${env} cluster"
    sh "sudo ./bin/plan-terraform.sh ${env}"
  }

  stage('\u277B Create/Update Service') {
    echo "\u277B Creating/Updating ECS Service in ${env} cluster"
    sh "sudo ./bin/apply-terraform.sh"
  }
}
