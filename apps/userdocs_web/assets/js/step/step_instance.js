const browserAutomation = require('../electron/browser_automation.js')

const COMPLETE = "complete"
const FAILED = "failed"
const STARTED = "started"

function start(step_instance) {
  step_instance.status = STARTED
  return step_instance
}

function succeed(step_instance) {
  step_instance.status = COMPLETE
  return step_instance
}

function fail(step_instance, error) {
  const curatedError = {
    name: error.name, 
    message: error.message,
    stack: error.stack
  }
  step_instance.errors.push(curatedError)
  step_instance.status = FAILED
  return step_instance
}

function stepInstanceHandler(stepInstance, config) {
  const functions = {
    "Navigate": async () => { 
      return browserAutomation.navigate(config.browser, stepInstance.attrs.page.url) 
    },
    //"Wait": wait,
    "Click": async () => { 
      return browserAutomation.click(config.browser, stepInstance.attrs.element.selector) 
    },
    "Fill Field": async () => { 
      return browserAutomation.setValue(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.text) 
    },
    "Apply Annotation": async () => { 
      const applyAnnotationFunction = async function(stepInstance, done) {
        try {
          await window.userdocs.waitForElement(stepInstance);
          const apply = window.userdocs.annotations(stepInstance.attrs.annotation.annotation_type.name)
          console.log(apply)
          apply(stepInstance)
          done(true)
        } catch(error) {
          done(error)
        }
      }
      return browserAutomation.applyAnnotation(config.browser, stepInstance, applyAnnotationFunction) 
    },
    "Set Size Explicit": async () => { 
      return browserAutomation.setSize(config.browser, stepInstance.attrs.width, stepInstance.attrs.height) 
    },
    "Full Screen Screenshot": async () => { 
      return browserAutomation.fullScreenScreenshot(config.browser) 
    },
    "Mouse Down, Mouse Up": async () => { 
      return browserAutomation.mouseDownMouseUp(config.browser, stepInstance.attrs.element.selector) 
    },
    "Clear Annotations": async () => { 
      return browserAutomation.clearAnnotations(config.browser) 
    },
    "Element Screenshot": async () => { 
      return browserAutomation.elementScreenshot(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.element.strategy) 
    },
    "Scroll to Element": async () => { 
      return browserAutomation.scrollIntoView(config.browser, stepInstance.attrs.element.selector) 
    },
    "Send Keys": async () => { 
      return browserAutomation.sendKeys(config.browser, text) 
    },
    "Send Enter Key": async () => { 
      return browserAutomation.sendEnterKey(config.browser) 
    },
  }
  const funk = functions[stepInstance.attrs.step_type.name]
  if ( funk ) {
    return funk
  } else {
    throw new Error(stepInstance.attrs.step_type.name + " Not implemented by stepInstanceHandler")
  }
}

module.exports.stepInstanceHandler = stepInstanceHandler
module.exports.fail = fail
module.exports.succeed = succeed
module.exports.start = start
module.exports.COMPLETE = COMPLETE
module.exports.FAILED = FAILED
module.exports.STARTED = STARTED