const { getElement } = require('../commands/elements.js')

function click(step) {
  const selector = step.attrs.element.selector
  const strategy = step.attrs.element.strategy
  const element = getElement(strategy, selector)
  try {
    element.click()
    step.status = "complete"
    return step
  } catch (error) {
    step.errors.push(error)
    return step
  }
}

function fillField(step) {
  const selector = step.attrs.element.selector
  const strategy = step.attrs.element.strategy
  const text = step.attrs.text
  const element = getElement(strategy, selector)
  const event = new Event('input', { bubbles: true })

  try {
    console.log("Writing to field")  
    element.value = text
    element.dispatchEvent(event)
    step.status = "complete"
    return step
  } catch (error) {
    step.status = "failed"
    step.errors.push(error)
    return step
  }
}

function applyAnnotation(step) {
  const name = step.attrs.annotation.annotation_type.name
  console.log("applying annotation " + name)
  var apply = annotations(name)

  try {
    console.log("Attempting apply annotation")
    apply(step)
    step.status = "complete"
    console.log("applied annotation")
    return step
  } catch(error) {
    console.log("failed applied annotation")
    step.status = "failed"
    console.log(error)
    step.errors.push(error)
    return step
  }
}

module.exports.click = click;
module.exports.fillField = fillField;