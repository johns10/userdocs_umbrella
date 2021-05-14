import { Process } from './process'
import * as StepInstance from './stepInstance'
import { Configuration } from '../automation/automation'

export interface ProcessInstance {
  id: number,
  order: number,
  status: string,
  name: string,
  type: string,
  process: Process,
  stepInstances: Array<StepInstance.StepInstance>,
  errors: Array<Error>,
  warnings: Array<Error>
}

export async function execute(processInstance: ProcessInstance, handlerName: string, configuration: Configuration) {
  const statusHandlers: { [ key: string ]: Function } = {
    "not_started": async (processInstance: ProcessInstance, handlerName: string, configuration: Configuration) => { 
      start(processInstance)
      return ( await run(processInstance, handlerName, configuration) )
    },
    "complete": async (processInstance: ProcessInstance, handlerName: string, configuration: Configuration) => { 
      return processInstance
    },
    "failed": async (processInstance: ProcessInstance, handlerName: string, configuration: Configuration) => { 
      start(processInstance)
      return ( await run(processInstance, handlerName, configuration) )
    }
  }

  const handler = statusHandlers[processInstance.status]
  try {
    return ( await handler(processInstance, handlerName, configuration) )
  } catch (error) {
    processInstance.status = 'failed'
    processInstance.errors.push(error)
    return processInstance
  }
}


function start(processInstance: ProcessInstance) {
  //console.log(`Starting Process Instance ${processInstance.name}`) 
}

async function run(processInstance: ProcessInstance, handlerName: string, configuration: Configuration) {
  for(const stepInstance of processInstance.stepInstances) {

    const stepInstanceHandler = (StepInstance as { [key: string]: Function })[handlerName]
    const completedStepInstance = await stepInstanceHandler(stepInstance, configuration)

    if (completedStepInstance.status == 'failed') {
      console.warn(`Execution of process instance ${processInstance.name} failed on Step Instance ${stepInstance.name} for ${stepInstance.errors}`)
      processInstance.errors = processInstance.errors
        .concat(stepFailedError(processInstance, completedStepInstance))
        .concat(stepInstance.errors)
      processInstance.status = 'failed'
      return processInstance
    }
  }

  processInstance.status = 'success'
  return processInstance
}

export function stepFailedError(processInstance: ProcessInstance, stepInstance: StepInstance.StepInstance) {
  var error = new Error()
  error.name = 'StepExecutionFailed'
  error.message = 
    `Process Instance ${processInstance.id}, ${processInstance.name} failed while executing 
    StepInstance ${stepInstance.id}, ${stepInstance.name}`
  error.stack = ""
  return error
}
