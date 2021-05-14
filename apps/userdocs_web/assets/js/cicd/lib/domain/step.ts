import { gql } from 'graphql-request'
import { Page } from './page'
import { StepType } from './stepType'
import { Element } from './element'
import { Process } from './process'
import { Screenshot } from './screenshot'
import { Annotation } from './annotation'

export interface Step extends Object {
  order: number,
  name: string,
  url: string,
  text: string,
  width: number,
  height: number,
  stepType: StepType,
  element: Element,
  page: Page,
  process: Process,
  screenshot: Screenshot,
  annotation: Annotation
}

export const UPDATE_STEP_SCREENSHOT = gql `

`

export const STEP_SCREENSHOT = gql `
  fragment StepBase64 on Step {
    base64
  }
`