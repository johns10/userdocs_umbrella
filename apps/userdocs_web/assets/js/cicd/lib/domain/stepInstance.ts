import { Step } from './step'
import { Configuration } from '../automation/automation'
import { gql } from 'graphql-request'

export interface StepInstance {
  id: number,
  order: number,
  status: string,
  name: string,
  type: string,
  step: Step,
  errors: Array<Error>,
  warnings: Array<Error>
}

export async function execute(stepInstance: StepInstance, configuration: Configuration) {
  const statusHandlers: { [ key: string ]: Function } = {
    "not_started": async (stepInstance: StepInstance, configuration: Configuration) => { 
      start(stepInstance)
      return ( await run(stepInstance, configuration) )
    },
    "complete": async (stepInstance: StepInstance, configuration: Configuration) => {  
      return stepInstance
    },
    "failed": async (stepInstance: StepInstance, configuration: Configuration) => { 
      start(stepInstance)
      return ( await run(stepInstance, configuration) )
    }
  }

  const handler = statusHandlers[stepInstance.status]
  try {
    return ( await handler(stepInstance, configuration) )
  } catch (error) {
    console.warn(`Execution of step instance ${stepInstance.name} failed for ${error}`)
    stepInstance.status = 'failed'
    stepInstance.errors.push(error)
    return stepInstance
  }
}

function start(stepInstance: StepInstance) {
  //console.log(`Starting Step Instance ${stepInstance.name}`) 
}

async function run(stepInstance: StepInstance, configuration: Configuration)  {
  const handler = configuration.automationFramework.stepInstanceHandler(stepInstance)
  if(!handler) throw(`Handler for ${stepInstance.step.stepType.name} not implemented`)

  return ( await runWithRetries(stepInstance, handler, configuration, 0, 2, null) )
}

async function runWithRetries(stepInstance: StepInstance, handler: Function, configuration: Configuration, retry: number, maxRetries: number, error: Error | null) {
  if (stepInstance.status != 'success' && retry < maxRetries) {
    try {
      stepInstance = await handler(configuration.browser, stepInstance, configuration)
      stepInstance.status = "success"
      return stepInstance
    } catch(error) {
      console.warn(`Step Instance ${stepInstance.id}, ${stepInstance.name} execution failed, on retry ${retry} of ${maxRetries}`)
      await new Promise(resolve => setTimeout(resolve, 0));
      const retryStepInstance: StepInstance = await runWithRetries(stepInstance, handler, configuration, retry + 1, maxRetries, error)
      return retryStepInstance
    }
  } else {
    stepInstance.status = 'failed'
    if (error) stepInstance.errors.push(error)
    return stepInstance
  }
}

export const STEP_INSTANCE_STATUS = gql`
  fragment StepInstanceStatus on StepInstance {
    id
    status
  }
`

export const UPDATE_STEP_INSTANCE = gql `
  mutation UpdateStepInstance($id: ID!, $status: String! $step: StepInput) {
    updateStepInstance(id: $id, status: $status, step: $step) {
      id
      status
      step {
        id
        name
        screenshot {
          id
        }
      }
    }
  }
`

export const UPDATE_STEP_INSTANCE_STATUS = gql`
  ${STEP_INSTANCE_STATUS}
  mutation UpdateStepInstanceStatus($status: String!, $id: ID!) {
    UpdateStepInstance(id: $id, status: $status) {
      ...StepInstanceStatus
    }
  }
`

