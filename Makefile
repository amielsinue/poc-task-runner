# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

null:
	help

.PHONY: dev-init
dev-init: ## dev-init will install needed serverless plugins
	serverless plugin install -n serverless-localstack &&\
	serverless plugin install -n serverless-step-functions

.PHONY: dev-start
dev-start: ## dev-start will start localstack and deploy serverless and push lambdas to it
	docker-compose down && docker-compose up -d && make dev-deploy && make dev-push-lambdas && docker-compose logs -f

.PHONY: dev-deploy
dev-deploy: ## dev-deploy will run serverless and deploy changes
	serverless deploy --stage local

.PHONY: dev-push-lambdas
dev-push-lambdas: ## dev-push-lambdas will push lambdas to localstack
	npm run build && npm run export &&\
	awslocal lambda --region us-west-1 update-function-code --function-name task-runner-local-addTask --zip-file fileb://build/main.js.zip && \
	awslocal lambda --region us-west-1 update-function-code --function-name task-runner-local-pullQueuedTasksByUserId --zip-file fileb://build/main.js.zip && \
	awslocal lambda --region us-west-1 update-function-code --function-name task-runner-local-pullFirstTask --zip-file fileb://build/main.js.zip

.PHONY: dev-get-links
dev-get-links: ## dev-get-links will create a url so you can test lambda functions
	awslocal lambda create-function-url-config \
        --region us-west-1 \
        --function-name task-runner-local-addTask \
        --auth-type NONE &&\
	awslocal lambda create-function-url-config \
        --region us-west-1 \
        --function-name task-runner-local-pullQueuedTasksByUserId \
        --auth-type NONE &&\
  	awslocal lambda create-function-url-config \
            --region us-west-1 \
            --function-name task-runner-local-pullFirstTask \
            --auth-type NONE \
        | grep FunctionUrl

.PHONY: dev-list-sms
dev-list-sms: ## dev-list-sms will list you the orchestrator state machine executions
	awslocal stepfunctions --region us-west-1  list-executions --state-machine arn:aws:states:us-west-1:000000000000:stateMachine:orchestratorStateMachine

.PHONY: dev-start-sm
dev-start-sm: ## dev-start-sm will allow you to start a new orchestrator execution: make dev-start-sm name=01
	awslocal stepfunctions --region us-west-1 start-execution --state-machine arn:aws:states:us-west-1:000000000000:stateMachine:orchestratorStateMachine --name ${name}

.PHONY: dev-addTask
dev-addTask: ## dev-addTask will allow you to add test tasks
	serverless invoke local --stage local --function addTask --data {"body":{"context": "test"}}

.PHONY: dev-addTask
dev-firstTask: ## dev-firstTask will allow you to add test this lambda function firstTask
	serverless invoke local --stage local --function pullFirstTask

.PHONY: dev-list-tables
dev-list-tables: ## dev-list-tables will list the dynamoDb tables created
	AWS_REGION=us-west-1 awslocal dynamodb list-tables

.PHONY: dev-pull-pending-tasks
dev-pull-pending-tasks: ## dev-pull-pending-tasks will allow you to add test this lambda function pullQueuedTasksByUserId: make dev-pull-pending-tasks user_id=1111010101
	serverless invoke local --stage local --function pullQueuedTasksByUserId --data '{"user_id": "${user_id}"}'

.PHONY: dev-user-tasks
dev-user-tasks: ## dev-user-tasks will allow you to trigger userTasksStateMachine: make dev-user-tasks name=01 user_id=101010101102
	awslocal stepfunctions --region us-west-1 start-execution --state-machine arn:aws:states:us-west-1:000000000000:stateMachine:userTasksStateMachine --name ${name} --input "{\"user_id\":\"${user_id}\"}"