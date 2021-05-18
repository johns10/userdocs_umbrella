
import { AnnotationType } from './annotation_type'

export interface Annotation {
  id: string,
  name: string,
  label: string,
  x_orientation: string,
  y_orientation: string,
  size: number,
  color: string,
  thickness: number,
  x_offset: number,
  y_offset: number,
  font_size: number,
  font_color: string,
  annotation_type: AnnotationType
}