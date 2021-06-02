const COMPLETE = "complete"
const FAILED = "failed"
const STARTED = "started"

function start(step_instance) {
  step_instance.status = STARTED
  return step_instance
}

function succeed(step_instance) {
  step_instance.status = COMPLETE
  return step_instance
}

function fail(step_instance, error) {
  const curatedError = {
    name: error.name, 
    message: error.message,
    stack: error.stack
  }
  step_instance.errors.push(curatedError)
  step_instance.status = FAILED
  return step_instance
}

module.exports.fail = fail
module.exports.succeed = succeed
module.exports.start = start
module.exports.COMPLETE = COMPLETE
module.exports.FAILED = FAILED
module.exports.STARTED = STARTED