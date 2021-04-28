function browserClosed(payload) {
  const element = document.querySelector('#automated-browser-controls');
  const event = new CustomEvent("browser-closed", {
      bubbles: false,
      detail: payload
  })
  element.dispatchEvent(event)
}

function browserOpened(payload) {
  const element = document.querySelector('#automated-browser-controls');
  const event = new CustomEvent("browser-opened", {
      bubbles: false,
      detail: payload
  })
  element.dispatchEvent(event)
}

function handleStepStatusUpdate(stepInstance, config) {
  //console.log("handleStepStatusUpdate")
  if (stepInstance.step_id) {
    config.window.send('stepStatusUpdated', stepInstance)
  }
}

function stepStatusUpdated(stepInstance) {
  /*
  if (stepInstance.step_id) {
    if (stepInstance.attrs.screenshot != null) {
      if (stepInstance.attrs.screenshot.base_64 != null) {
        try {
          document
          .getElementById("screenshot-handler-component")
          .dispatchEvent(new CustomEvent("screenshot", {
            bubbles: false,
            detail: stepInstance
          }))
        } catch(e) {
          //console.log("Failed to update screenshot for step " + stepInstance.step_id)
        }
      }
    }
    try {
      document  
        .getElementById("step-" + stepInstance.step_id + "-status")
        .dispatchEvent(new CustomEvent("update-step", {
          bubbles: false,
          detail: stepInstance 
        }))
    } catch (e) {
      //console.log("Failed to send update to step-" + stepInstance.step_id + "-status")
    }
  }
  */
  try {
    //console.log("trying to update automation manager")
    document
      .getElementById("automation-manager-hook")
      .dispatchEvent(new CustomEvent("update-step-instance", {
        bubbles: false,
        detail: stepInstance
      }))
  } catch (e) {
    console.log("Failed to send update to step-instance: " + stepInstance.step_id)
  }
}

function processStatusUpdated(stepInstance) {
  console.log("Updating process " + stepInstance.attrs.step.process.id  + " status")
  try {
    document  
      .getElementById("process-" + stepInstance.attrs.step.process.id + "-runner")
      .dispatchEvent(new CustomEvent("update-process", {
        bubbles: false,
        detail: stepInstance 
      }))
  } catch (e) {
    console.log("Failed to send update to process-" + stepInstance.attrs.step.process.id + "-runner")
  }
}

module.exports.browserOpened = browserOpened
module.exports.browserClosed = browserClosed
module.exports.stepStatusUpdated = stepStatusUpdated
module.exports.processStatusUpdated = processStatusUpdated
module.exports.handleStepStatusUpdate = handleStepStatusUpdate