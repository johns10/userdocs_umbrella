import { Configuration, RunnerCallbacks } from '../runner/runner'
import * as ProcessInstance from './processInstance'
import * as Step from './step'
export interface Process {
  id: string,
  order: number,
  name: string,
  processInstance: ProcessInstance.ProcessInstance,
  steps: Array<Step.Step>
}

export async function execute(process: Process, browser: any, configuration: Configuration, callbacks: RunnerCallbacks, fetchStepHandler: Function) {
  if(!callbacks) throw (`Callbacks not passed properly.  An object of the shape { calbbacks: { step: { ... }}} is required.  Got ${callbacks}`)
  for(const callback of callbacks.process.preExecutionCallbacks) { 
    if(typeof callback != 'function') throw (`Received ${callback}.  Expected function. The callbacks object is probably wrong ${callbacks}`)
    process = await callback(process, browser, configuration) 
  }
  try {
    process = await callbacks.process.executionCallback(process, browser, configuration, callbacks, fetchStepHandler)
    for(const callback of callbacks.process.successCallbacks) { 
      process = await callback(process, browser, configuration) 
    }
  } catch(error) {
    for(const callback of callbacks.process.failureCallbacks) { 
      process = await callback(process, browser, configuration, error) 
    }
  }
  return process
}

export const handlers = {
  embedNewProcessInstance: async(process: Process) => {
    const processInstance: ProcessInstance.ProcessInstance = {
      order: process.order,
      status: "not_started",
      name: process.name,
      type: "stepInstance",
      processId: process.id,
      startedAt: new Date()
    }
    process.processInstance = processInstance
    return process
  },
  run: async(process: Process, browser: any, configuration: Configuration, callbacks: RunnerCallbacks, fetchStepHandler: Function) => {
    for(var step of process.steps) {
      step = await Step.execute(step, browser, configuration, callbacks, fetchStepHandler)
      if (step.stepInstance.status == 'failed') throw `Step ${step.id}, ${step.name} failed to execute`
    }
    return process
  },
  completeProcessInstance: async(process: Process) => {
    process.processInstance.status = 'complete'
    process.processInstance.finishedAt = new Date()
    return process
  },
  failProcessInstance: async (process: Process, browser: any, configuration: Configuration, error: Error) => {
    process.processInstance.status = 'failed'
    if (Array.isArray(process.processInstance.errors) == true) process.processInstance.errors.push(error)
    else process.processInstance.errors = [ error ]
    return process
  },
  nothing: async (process: Process) => { return process },
  fail: async (process: Process) => { throw "This process is expected to fail for test purposes" }
}