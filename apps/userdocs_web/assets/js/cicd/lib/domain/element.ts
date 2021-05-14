
import { Strategy } from './strategy'

export interface Element {
  name: string,
  selector: string,
  strategy: Strategy
}