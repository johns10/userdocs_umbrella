import { StepInstance } from './stepInstance'
import * as ProcessInstance from './processInstance'

export interface Job {
  id: number,
  order: number,
  status: string,
  name: string,
  errors: Array<Error>
  stepInstances: Array<StepInstance>,
  processInstances: Array<ProcessInstance.ProcessInstance>
}