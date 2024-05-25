const { ulid } = require("ulid");
const {storeTask, pullTasksByUserId, pullFirstTask} = require("./data");


module.exports.addTask = async (event) => {
  console.log('adding task!', event);
  const payload = JSON.parse(event.body || '{}')

  const {task_id = ulid()} = payload
  try{
    const result = await storeTask(task_id, payload);
    console.log('result of saving task', result);
  } catch (e) {
    console.log('Error Saving Task', e);
  }
  return event;
}

module.exports.pullFirstTask = async (event) => {
  console.log('pulling task!', event);
  try{
    const result = await pullFirstTask();
    console.log('pulling first pending task', result);
    return result;
  } catch (e) {
    console.log('Error pulling Task', e);
    return {"error": "No pending task found!"}
  }

  return {};
}

module.exports.pullQueuedTasksByUserId = async (event) => {
  console.log('pulling queued tasks by User ID! ');
  console.log(JSON.stringify(event))
  try{
    const result = await pullTasksByUserId(event.user_id);
    console.log('pulling queued tasks', result);
    return result;
  } catch (e) {
    console.log('Error pulling Tasks', e);
    return {"error": "No queued task found!"}
  }
  return {};
}

module.exports.runTask = async (event) => {
  console.log('running task', event);
  // call task;
  return true;
}