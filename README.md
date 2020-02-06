<img src='https://github.com/byaws/aws-ecs-codepipeline-deploy/raw/master/screenshots/architecture.png' border='0' alt='architecture' />

Implementation of automated distribution through [aws](https://aws.amazon.com/ko/) product [ecs](https://aws.amazon.com/ko/ecs/) and [codepipeline](https://aws.amazon.com/ko/codepipeline/)

> Create smart aws diagrams [Cloudcraft](https://cloudcraft.co/)

<br />

## What is AWS ?

Whether you're looking for compute power, database storage, content delivery, or other features with services operated by Amazon, 

AWS has services to help you build sophisticated applications with increased flexibility, scalability, and reliability.

## What is ECS ?

Amazon Elastic Container Service (Amazon ECS) is a fully managed container orchestration service. 

Customers such as Duolingo, Samsung, GE, and Cook Pad use ECS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

Additionally, because ECS has been a foundational pillar for key Amazon services, 

it can natively integrate with other services such as Amazon Route 53, Secrets Manager, AWS Identity and Access Management (IAM), and Amazon CloudWatch providing you a familiar experience to deploy and scale your containers.

▾ How Amazon ECS works

<img src='https://github.com/byaws/aws-ecs-codepipeline-deploy/raw/master/screenshots/ecs-works.png' border='0' alt='ecs-works' />

## What is CodePipeline ?

AWS CodePipeline is a fully managed continuous delivery service that helps you automate your release pipelines for fast and reliable application and infrastructure updates.

CodePipeline automates the build, test, and deploy phases of your release process every time there is a code change, based on the release model you define.

▾ How Amazon CodePipeline works

<img src='https://github.com/byaws/aws-ecs-codepipeline-deploy/raw/master/screenshots/codepipeline-works.png' border='0' alt='codepipeline-works' />

## Continuous Deployment with CodePipeline

### Add a Build Specification File to Your Source Repository

CodeBuild to build your Docker image and push the image to Amazon ECR.

Add a `buildspec.yml` file to your source code repository to tell CodeBuild how to do that.

[Details](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cd-pipeline.html)

▾ buildspec.yml

```bash
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - REPOSITORY_URI={ ECR_URI }
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=${COMMIT_HASH:=latest}
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"{ ECS_SERVICE_CONTAINER }","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
    files: imagedefinitions.json
```

### Add a DockerFile to Your Source Repository

Create a dockerfile to run in codebuild.

[Dockerfile Refernce](https://docs.docker.com/engine/reference/builder/)

▾ Dockerfile

```bash
# Version node lts
FROM node:lts

# Dockerfile manager
LABEL maintainer="AGUMON <ljlm0402@gmail.com>"

# Copy Project
COPY . /aws-ecs-codepipeline-deploy

# Install npm latest
RUN npm install -g npm@latest

# Work to Project
WORKDIR /aws-ecs-codepipeline-deploy

# Install dependencies
RUN npm install

# Set process port
EXPOSE 3000

# Start process
CMD ["npm", "start"]
```
