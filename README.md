# Poor man's enterprise-like CI/CD toolchain
## Workshop @ Night of Chances 2023

This repository contains all the things you'll need for this workshop. We will experience building a modern integrated application development environment on a student's budget. Together, we'll understand how it works and how to make your life easier by doing things a bit more sophisticated.

## Prerequisites

For this workshop, you will need **Docker** installed. Make sure to assign it enough resources (optimal would be at least 8 GB of RAM if you can't provide that, keep in mind the more you assign the smoother it will run). Also, assure that your port `80` and `443` and `3000` are not occupied on your localhost, because we will need them later on.

## Table of contents

* [Setting up GitLab](#setting-up-gitlab)
* [Our first pipeline](#our-first-pipeline)
* [Pizza API](#pizza-api)
* [Vault](#vault)
* [Terraform](#terraform)

## Setting up GitLab

In this section we will set up **GitLab**, which will not only act as our Git server, but as a whole DevOps platform which will enable us to do some of the cool stuff we are going to.

### Quick Start

A simple `Makefile` with some helper scripts enables you to get GitLab up and running with almost no effort. Make sure your Docker daemon is running and execute the following commands in a command line shell of your choice.

```bash
cp .env.default .env
make
```

You will see two containers booting up in Docker. Wait until you can log in to GitLab on `localhost` in your browser with the `root` user using the `secretpassword`. Once this is working, GitLab is in a __healthy__ state and you basically have a Git server up and running.

Furthermore, we will need **GitLab Runner** (the second container). For that, we also prepared a simple bash script that should do the job for you.

```bash
make runner-register
```

Give it some time (the execution of the Ruby command in the background is not the fastest), until it terminates successfully. You should now be able to see the runner registered in the Admin settings of your GitLab. 

In addition, you will see some configuration files in the `gitlab` repository, including configuration for the GitLab Runner.


### Steps

If something did not work for you, or you are just interested in the details, the following section will cover everything we automated with the two `make` commands in detail. Basically we did the following steps:

* Export GITLAB_HOME environment variable
* Change root password
* Start all services
* Wait for GitLab to start (takes about 6-10 minutes)
* Login to Gitlab
* Get the token for registering runner
* Register runner

#### Step 0 : Export GITLAB_HOME environment variable

```bash
export GITLAB_HOME=$(pwd)/gitlab
```

#### Step 1: Change root password

Edit this line in the docker-compose.yml file

```
gitlab_rails['initial_root_password'] = 'yourpasswordhere'
```

#### Step 2: Start all services
```bash
docker-compose up -d
```

Note: If you have Mac computer with newer ARM CPU, please use this YML file instead, it uses ARM compatible image:
```bash
docker-compose -f docker-compose-arm.yml up -d
```

Patiently wait for GitLab to start (if you are checking logs for now you will see the booting process, ignore all the runner errors for now)
- It'll take about 6 minutes for nginx to start responding
- Complete start may take 6-10 minutes

Note: you can check the status with the following command:
```bash
docker logs -f noc-gitlab-ce
```

#### Step 3: Login to Gitlab
Log in using `root` user and pw that you obtained (url is http://localhost)

#### Step 4: Get the token for registering runner

Copy the runner register token from the UI (`Menu -> Admin -> Runners`) or via console through a rails call (takes about 1 minute)

```bash
docker exec noc-gitlab-ce gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"
```

#### Step 5: Register runner

To register our runner container, you need to execute the following command. Make sure to replace the `--registration-token` option with the token you just retrieved from the UI or via the rails call.

```bash
docker exec -it noc-gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://noc-gitlab-ce" \
  --clone-url "http://noc-gitlab-ce" \
  --registration-token "REPLACE_WITH_TOKEN" \
  --executor "docker" \
  --docker-image docker:stable \
  --description "docker-runner" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected" \
  --docker-network-mode "gitlab-network" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```

#### Finalize
Now, if you reload your GitLab, log in and navigate to the Admin settings, you should see the already registered runner visible, up and running in your UI.

## Our first pipeline

To test all of this, we will create a first public repository and add a really simple pipeline, just to test if our GitLab and GitLab Runner is working and correctly communicating. For that, add the following `.gitlab-ci.yml` to a newly created public repository.

```
stages:
  - greet

hello:
  stage: greet
  script:
    - echo Hello Night of Chances 2023
```

After commiting the changes, the Pipeline will start including our `greet` stage. If you are interested, examine the output of the stage and watch the docker images being pulled, containers spun up for executing all the individual stages.

## Pizza API

This repository contains a really simple Node.js application built with the popular Express framework. We will use this application as an example for our CI/CD pipeline.

For more information take a look at the [README.md](./pizza-api/README.md).

## Vault

In this section we will show a brief introduction on how to obtain secrets from external sources, namely from failry popular tool called Vault.

For more information take a look at the [README.md](./vault/README.md).

## Terraform

In this section we will introduce you to a widely used IaC (infrastructure as coce) tool called Terraform.

For more information take a look at the [README.md](./terraform/README.md).
