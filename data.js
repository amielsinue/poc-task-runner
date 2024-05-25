const AWS = require('aws-sdk');
const {StatusType} = require("./types");
const { ulid } = require("ulid");

const docClient = new AWS.DynamoDB.DocumentClient({
  apiVersion: '2012-08-10',
  endpoint: 'http://localhost:4566'
});
// Create DynamoDB service object.
const ddb = new AWS.DynamoDB({
  apiVersion: "2012-08-10",
  endpoint: 'http://localhost:4566'
});

module.exports.pullFirstTask = async (status=StatusType.PENDING) => {
  const params = {
    ExpressionAttributeNames: { "#status": "status"}, //, "#GSI1SK": "GSI1SK"
    ExpressionAttributeValues: {
      ':status' : {
        'N': `${status}`
      },
    },
    IndexName: 'StatusIndex',
    KeyConditionExpression: '#status = :status', // AND #GSI1SK = :GSI1SK
    TableName:  process.env.DYNAMODB_TASKS_TABLE,
    Limit: 1,
  };

  const data = await ddb.query(params).promise();
  return data['Items'].map((item) => {
    return {
      'user_id': item.user_id.S,
      'task_id': item.task_id.S,
      'status': item.status.S,
      'priority': item.priority.S,
      'context': item.context || {},
    }
  }).shift();
};

module.exports.pullTasksByUserId = async (user_id, status = StatusType.QUEUED) => {
  const params = {
    ExpressionAttributeNames: {
      "#user_id": "user_id",
      "#status": "status"
    },
    ExpressionAttributeValues: {
      ':status' : {
        'N': `${status}`
      },
      ':user_id': {
        'S': `${user_id}`
      }
    },
    IndexName: 'UserStatusStatusIndex',
    KeyConditionExpression: '#user_id = :user_id and #status = :status',
    // FilterExpression: '#status = :status',
    TableName:  process.env.DYNAMODB_TASKS_TABLE,
    Limit: 100,
  };
  console.log('pullTasksByUserId.query params', params);
  const data = await ddb.query(params).promise();
  return data['Items'].map((item) => {
    return {
      'user_id': item.user_id.S,
      'task_id': item.task_id.S,
      'status': item.status.N,
      'priority': item.priority.N,
      'context': item.context || {},
    }
  })

};

module.exports.storeTask = async (task_id, task) => {
  const { priority=0, user_id=ulid() } = task

  const item = {
    user_id: user_id.toString(),
    task_id: task_id.toString(),
    status: StatusType.PENDING,
    priority: priority,
    context: task.context
  };

  const params = {
    TableName: process.env.DYNAMODB_TASKS_TABLE,
    Item: item
  }
  console.log('storeTask.put params', params);
  return docClient.put(params).promise();
};