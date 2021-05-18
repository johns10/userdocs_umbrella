import { Process } from './process'
import * as StepInstance from './stepInstance'
import { Configuration } from '../automation/automation'
import { gql } from 'graphql-request'

export interface ProcessInstance {
  id?: string,
  order: number,
  status: string,
  name: string,
  type: string,
  process?: Process,
  processId: string,
  stepInstances?: Array<StepInstance.StepInstance>,
  errors?: Array<Error>,
  warnings?: Array<Error>,
  startedAt?: Date,
  finishedAt?: Date
}

export async function execute(processInstance: ProcessInstance, handlerName: string, configuration: Configuration) {
  const handler = async(processInstance: ProcessInstance, handlerName: string, configuration: Configuration) => { 
    start(processInstance)
    return ( await run(processInstance, handlerName, configuration) )
  }

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

    const stepInstanceHandler = StepInstance[handlerName]
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

  processInstance.status = 'complete'
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

export function allowedFields(processInstance: ProcessInstance) {
  var stepInstances = []
  for(const stepInstance of processInstance.stepInstances) {
    stepInstances.push(StepInstance.allowedFields(stepInstance))
  } 
  return {
    id: processInstance.id,
    status: processInstance.status,
    stepInstances:  stepInstances
  }
}

export const UPDATE_PROCESS_INSTANCE = gql `
  mutation UpdateProcessInstance($id: ID!, $status: String!, $stepInstances: [ StepInstanceInput ] ) {
    updateProcessInstance(id: $id, status: $status, stepInstances: $stepInstances) {
      id
      status
    }
  }
`