# Pizza API 🍕

Welcome to the Pizza API, a really simple (yet awesome) Node.js application built with the popular framework Express.

## Getting Started
You can start the application with Docker Compose, just run `docker-compose -f docker-compose-pizza.yml up` within the `pizza-api` directory.

The application will listen on [localhost:3000](http://localhost:3000).

If you open the URL in your browser, you should see your first generated pizza.

```json
["Sourdough","Mozarella","Tomato sauce","Egg","Olives","Salami"]
```

You can also specify to get a white pizza, a so called Pizza Bianca, by adding the URL paramter `isBianca` ([localhost:3000/?isBianca=1](http://localhost:3000/?isBianca=1)). You'll see the lack of tomato sauce in the generated pizza.

```json
["Sourdough","Mozarella","Prosciutto","Egg","Cremini"]
```

## Running Tests

To test our suffisticated pizza logic, some tests were added. The tests were written with the JavaScript testing framework **Jest**.

To run the tests by yourself, you can execute a command within the container.

```bash
docker exec -it pizza-api npm run test
```

You'll see the successful testing output in your console.

## Use your own GitLab for running your CI/CD pipeline

If you set up the GitLab server as described in the root [README.md](../README.md) file, you can now start using it for this project. For this you need to create a **New project** within GitLab. Choose the **Create blank project** option, choose a name for you project (e.g. Pizza API), and set the repository to **Public**. Also uncheck the **Initialize repository with a README** option, so our project is initialized completely empty.

After that, just copy the `pizza-api` folder to some location and follow the instructions displayed in the blank repository on GitLab (Push an existing folder). The commands should look like the following:

```bash
cd FOLDER_NAME
git init --initial-branch=main
git remote add origin ORIGIN_URL
git add .
git commit -m "Initial commit"
git push -u origin main
```

After that you can navigate to the **CI/CD** section of your GitLab project, and you'll see the pipeline doing its job.

## Examine the GitLab pipeline

Examine the **Job** within GitLab a bit closer. Then take a look at the `.gitlab-ci.yml` file, which contains the definition of this pipeline. You'll see three stages (stages are parts which make up a pipeline), `hello`, `install` and `test`. As the name says, the stages do a greeting, installing dependencies using npm and executing tests, just as you did manually earlier.
 
