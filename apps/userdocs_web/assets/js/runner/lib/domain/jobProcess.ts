import * as Process from './process'
export interface JobProcess {
  id: string,
  jobId: string,
  order: number,
  processId: string,
  process: Process.Process,
  type: string
}

export function allowedFields(jobProcess: JobProcess) {
  return "Not Implemented"
}