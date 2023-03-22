# Terraform

Welcome to this part of our workshop. We will introduce you to a tool called **Terraform**. It is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

Infrastructure as code is a concept, where we use some form of markup language ("code") to define our infrastructure. This enables us to work on files instead of web GUIs and command lines. It also allows us to track our changes with a version control system of our choice (mostly Git is used) and use tools (editors, ...) that we are familiar with.

## Getting Started

Again, we prepared something in this folder (terraform) for you, to show you the concept of how we can use a tool such as Terraform in our landscape.

We will use **GitLab Runner** (maybe you'll already noticed the `.gitlab-ci.yml` file in this directory). In that case, GitLab is not just our Git Server but it actually is much more than that, becoming our **Orchestration Engine** for not just our code CI/CD pipeline, but even our infrastructure (or much different stuff, as you will find out later when we start using Terraform).

## About the State of our resources

Terraform stores the current state about your managed resources and configuration within a so-called **state file**. As long as there is only one person who creates, changes and configures resources with the help of Terraform, it is sufficient if the Terraform State is located on the local machine of this person. Since this is not the case in the everyday life of an enterprise, the Terraform state must be managed at a remote single source of truth in order to avoid conflicts (Imagine two team members making changes that alter the current state and thus the state. If this were to be stored locally twice, it would no longer be possible to determine which is now the valid one). 

Fortunately, GitLab offers exactly this feature. We can store our **state** within GitLab and let it take care about it. For that we have to create an **access token** which enables Terraform to securely access our state. Navigate to **Preferences** - **Access Tokens** and create a token with the following specifications:

* Token name: `terraform`
* Expiration date: Keep default
* Selected scopes: api

**Important**: Note the token displayed somewhere, you won't be able to view it a second time. If you already moved onwards and forgot to note it, just delete and re-create with the same specifications. We will now use this token to give Terraform access to our GitLab managed state data.

Next, you need to create a **New project** within GitLab. Choose the **Create blank project** option, choose a name for you project (e.g. Terraform), and set the repository to **Public**. Also uncheck the **Initialize repository with a README** option, so our project is initialized completely empty.

We now somehow need to add the token we just created as a CI/CD variable, so our pipeline can access it. For this, navigate to your project, go to **Settings** - **CI/CD** and expand the **Variables** section. Then, create the following two variables.

* `TF_USERNAME`: `terraform` (Uncheck the unprotected and masked option)
* `TF_PASSWORD`: The value of the token you just created (Uncheck the unprotected option, check the masked option so we don't see our token in cleartext in log output)

After that, just copy the `terraform` folder containing our `.gitlab-ci.yml` file to some location and follow the instructions displayed in the blank repository on GitLab (Push an existing folder). The commands should look like the following:

```bash
cd FOLDER_NAME
git init --initial-branch=main
git remote add origin ORIGIN_URL
git add .
git commit -m "Initial commit"
git push -u origin main
```

Spoiler alert: This will eventually fail, but we will get to fix that later on.

Once you've pushed the infrastructure code to your new project, you will see the progress of your pipeline run under the **CI/CD** section. Expand the pipeline and its steps, to see further log output.

## Let's spin up some resources 

Usually we use Terraform for defining our infrastructure resources (eg cloud resources like virtual machines, databases or load balancers). But in fact terraform is just using a so-called "provider" to manage those cloud resources. 
In fact, there are Terraform providers for many things, and you could even write one yourself for creating a spotify playlist or even ordering pizza. 
Think of the provider as the connection (the "glue") between Terraform and the target system (which is often accessed via APIs).

In our case, we will use a provider which enables us to create Docker resources, for example containers.
To pull off this somewhat unusual but highly interesting stunt, we have to adjust the configuration of our Gitlab runner a little. 
Update the volume configuration in the `[runners.docker]` section of the configuration file under `gitlab/gitlab-runner/config.toml`, to include the volume mount `"/var/run/docker.sock:/var/run/docker.sock"`. This will make the Docker socket available in our container. It should look something like this:

```toml
[[runners]]
# ...
  [runners.docker]
  # ...
  volumes = [
    "/cache", 
    "/var/run/docker.sock:/var/run/docker.sock"
  ]
```

Now take a closer look at the definition of our Terraform code , `backend.tf`. 
You will notice that we reference exactly this `/var/run/docker.sock` in our configuration:

```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

Try to push your code in the `terraform` folder again, for example by running

```shell
git commit --allow-empty -m "Trigger CI/CD run"
git push
```

and examine the run in your GitLab and Docker clients.

You will see the different stages running of the pipeline in your GitLab. 
If the `validate` and `build` stage succeeded, the pipeline will be paused until you manually trigger the `deploy` stage.
The deploy stage will now create a container locally on your computer with the help of Terraform, as already mentioned, this is a bit of a stunt but simulates the principle of creating resources with Terraform a bit.

To close the circle, we included an image of the **pizza-api** that we just deployed with the container. 
Visit your `localhost:3000` and you will see the first generated pizza.

PS: This is just an example, just like everything with this workshop, you can extend this even more, start building your images with GitLab, consume from the local registry or even set up a huge scalable cloud infrastructure in AWS, Google Cloud, Azure or multiple of the mentioned cloud providers.
