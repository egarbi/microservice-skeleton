Microservices default files
-----------------------------
# Description #
These is an skeleton repo used to create microservices from scratch.
Use the import feature in bitbucket to create a new repo and start to build it from there.

## Files and directory description ##
```
├── Jenkinsfile 
├── bin
│   ├── apply-terraform.sh
│   ├── build-image.sh
│   ├── docker-entrypoint.sh
│   ├── image-version.sh
│   ├── plan-terraform.sh
│   ├── publish-image.sh
│   └── test-image.sh
└── terraform
    ├── container_definitions.json
    ├── datasources.tf
    ├── main.tf
    └── variables.tf
```
### Jenkinsfile ### 
This is what is read from Jenkins and basically its running the bash script in secuence from bin/

### Bash Scripts ###
`image-version.sh` it sets the shared variable needed for all other scripts.

`build-image.sh` it will compile the binary from src/ and create an docker image used to run the binary.

`docker-entrypoint.sh` is used by the docker image created as [entrypoint](https://docs.docker.com/engine/reference/builder/#entrypoint)

`test-image.sh` it will test the image created with build-image.sh before deployment (CI).

`publish-image.sh` uplaad the docker image to the proper ECR repo. If the repo doesnt exist, it going to create it.

`plan-terraform.sh` shows the infra changes that terraform will apply if next step. Terraform code is defined on terraform/ directory.

`apply-terraform.sh` apply the plan proposed in plan-terraform.sh

### Terraform Code ###
[Terraform](https://www.terraform.io/) is a tool to have infrastracture as a code.

`container_definitions.json` [ECS Task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html).

`datasources.tf` This is a set of aws resources already created that will taken as input.
i.e: VPC and Load Balancer and all resources related.

More details about Data Sources can be found here:  https://www.terraform.io/docs/providers/aws/index.html#

`main.tf` This are the AWS resources that will be created within this project.

Basically an ECS service will be created/updated based on container_definitions provided and 

attached to the internal Load Balancer for the service be able to be reachable from the VPC.

`variables.tf` This is the file where variables used my the terraform module will be set. This file structure is the recommended as for the best practice of terraform.
