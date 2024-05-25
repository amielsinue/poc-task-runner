Requirements:
- Docker https://docs.docker.com/desktop/install/mac-install/  
- localstack
    ```shell
    brew install localstack
    ```
- node:
    ```shell
    brew install node@12
    ```
  or try to use nvm and do
    ```shell
    nvm install 12
    nvm use 12
    ```
- serverless
    ```shell
    npm install -g serverless
    ```
  

Start local Dev Env


```shell
make dev-init && make dev-start
```

On another shell run this to get urls:
```shell
make dev-
```

Copy the url of addTask and replace it here:
```shell
curl --location --request POST 'http://eee9865e8961215c47ce2e8c1192f5d5.lambda-url.us-west-1.localhost.localstack.cloud:4566/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "priority": 0,
    "task_id": 1,
    "user_id": 1,
    "context": {
      "name": "test 1"
    }
}'
```
You should be able to post tasks

Once you post few tasks, you can run:
```shell
make dev-start-sm name=01
```

Run this to see the status of the state machine execution
```shell
make dev-list-sms
```

Test UserTasks State Machine
```shell
make dev-user-tasks name=04 user_id=1
```

You can see dynamo db table accessing: http://localhost:8001/tables/


Make commands:
```shell
help                           This help
dev-init                       dev-init will install needed serverless plugins
dev-start                      dev-start will start localstack and deploy serverless and push lambdas to it
dev-deploy                     dev-deploy will run serverless and deploy changes
dev-push-lambdas               dev-push-lambdas will push lambdas to localstack
dev-get-links                  dev-get-links will create a url so you can test lambda functions
dev-list-sms                   dev-list-sms will list you the orchestrator state machine executions
dev-start-sm                   dev-start-sm will allow you to start a new orchestrator execution: make dev-start-sm name=01
dev-addTask                    dev-addTask will allow you to add test tasks
dev-firstTask                  dev-firstTask will allow you to add test this lambda function firstTask
dev-list-tables                dev-list-tables will list the dynamoDb tables created
dev-pull-pending-tasks         dev-pull-pending-tasks will allow you to add test this lambda function pullQueuedTasksByUserId: make dev-pull-pending-tasks user_id=1111010101
dev-user-tasks                 dev-user-tasks will allow you to trigger userTasksStateMachine: make dev-user-tasks name=01 user_id=101010101102

```