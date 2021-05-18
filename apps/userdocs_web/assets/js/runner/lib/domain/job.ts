import * as StepInstance from './stepInstance'
import * as ProcessInstance from './processInstance'
import { Configuration } from '../automation/automation'
import { gql } from 'graphql-request'

export interface Job {
  id: string,
  order: number,
  status: string,
  name: string,
  errors: Array<Error>
  stepInstances: Array<StepInstance.StepInstance>,
  processInstances: Array<ProcessInstance.ProcessInstance>
}

export function allowedFields(job: Job) {
  var stepInstances = []
  for(const stepInstance of job.stepInstances ? job.stepInstances : []) {
    stepInstances.push(StepInstance.allowedFields(stepInstance))
  } 
  var processInstances = []
  for(const processInstance of job.processInstances ? job.processInstances: []) {
    processInstances.push(ProcessInstance.allowedFields(processInstance))
  } 
  return {
    id: job.id,
    status: job.status,
    stepInstances:  stepInstances,
    processInstances: processInstances
  }
}


export const UPDATE_JOB = gql `
  mutation UpdateJob($id: ID!, $status: String!, $processInstances: [ ProcessInstanceInput ] $stepInstances: [ StepInstanceInput ] ) {
    updateJob(id: $id, status: $status, processInstances: $processInstances, stepInstances: $stepInstances) {
      id
      status
    }
  }
`