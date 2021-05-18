import { gql } from 'graphql-request'
import * as StepInstance from './stepInstance'
import { Page } from './page'
import { StepType } from './stepType'
import { Element } from './element'
import { Process } from './process'
import * as Screenshot from './screenshot'
import { Annotation } from './annotation'
import { Configuration, RunnerCallbacks } from '../runner/runner'
import { stepInstance } from '../../queries'
import { getNamedType } from 'graphql'
export interface Step extends Object {
  id: string,
  order: number,
  name: string,
  url: string,
  text: string,
  width: number,
  height: number,
  step_type: StepType,
  element: Element,
  page: Page,
  process: Process,
  screenshot: Screenshot.Screenshot,
  annotation: Annotation,
  stepInstance?: StepInstance.StepInstance
}

export async function execute(step: Step, browser: any, configuration: Configuration, callbacks: RunnerCallbacks, fetchHandler: Function)  {
  // console.debug(`Running Step ${step.name}`)
  const handler = fetchHandler(step)
  if(!handler) throw(`Handler for ${step.step_type.name} not implemented`)
  for(const callback of callbacks.step.preExecutionCallbacks) { 
    step = await callback(step, handler, browser, configuration) 
  }
  try {
    step = await callbacks.step.executionCallback(step, handler, browser, configuration)
    for(const callback of callbacks.step.successCallbacks) { 
      step = await callback(step, handler, browser, configuration) 
    }
  } catch(error) {
    for(const callback of callbacks.step.failureCallbacks) { 
      step = await callback(step, handler, browser, configuration, error) 
    }
  }
  return step
}

export const handlers = {
  embedNewStepInstance: async(step: Step) => {
    const stepInstance: StepInstance.StepInstance = {
      order: step.order,
      status: "not_started",
      name: step.name,
      type: "stepInstance",
      stepId: step.id,
      startedAt: new Date()
    }
    step.stepInstance = stepInstance
    return step
  },
  run: async (step: Step, handler: Function, browser: any, configuration: Configuration) => {
    const completedStep = await runWithRetries(step, handler, browser, configuration, 0, null)
    return completedStep
  },
  completeStepInstance: async(step: Step) => {
    step.stepInstance.status = 'complete'
    step.stepInstance.finishedAt = new Date()
    return step
  },
  failStepInstance: async (step: Step, handler: Function, browser: any, configuration: Configuration, error: Error) => {
    step.stepInstance.status = 'failed'
    if (Array.isArray(step.stepInstance.errors) == true) step.stepInstance.errors.push(error)
    else step.stepInstance.errors = [ error ]
    return step
  },
  nothing: async (step: Step) => { return step },
  fail: async (step: Step) => { throw "This step is expected to fail for test purposes" }
}

async function runWithRetries(step: Step, handler: Function, browser: any, configuration: Configuration, retry: number, error: Error | null) {
  const maxRetries = configuration.maxRetries
  if (retry < maxRetries) {
    try {
      step = await handler(browser, step, configuration)
      return step
    } catch(error) {
      console.warn(`Step ${step.id}, ${step.name} execution failed, on retry ${retry} of ${maxRetries}`)
      await new Promise(resolve => setTimeout(resolve, retry ^ 3));
      const retryStep: Step = await runWithRetries(step, handler, browser, configuration, retry + 1, error)
      return retryStep
    }
  } else {
    throw error
  }
}

export function allowedFields(step: Step) {
  var fields: any = {
    id: step.id,  
    order: step.order
  }
  if(step.screenshot) fields.screenshot = step.screenshot
  return fields
}

export const UPDATE_STEP_SCREENSHOT = gql `

`

export const STEP_SCREENSHOT = gql `
  fragment StepBase64 on Step {
    base64
  }
`