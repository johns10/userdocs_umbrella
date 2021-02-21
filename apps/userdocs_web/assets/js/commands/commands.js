import { configure } from "nprogress"

function handle_message(message, configuration) {
  const log_string = "Received " + message.type + " message.  "
  console.log(log_string)
  if (message.type == 'process') {
    message.payload.type = 'process'
    handle_job(message.payload, configuration)
  } else if (message.type == 'step') {
    message.payload.type = 'step'
    handle_step(message.payload, configuration)
  } else if (message.type == 'configuration') {
    configure_environment(message.payload)
  }
}

function configure_environment(payload) {
  console.log("Current Configuration") 
  chrome.storage.local.set({strategy: payload.strategy}, function() {
    console.log('Selector Strategy is set to ' + payload.strategy.name);
  });
}

function handle_job(job, configuration) {
  const status = job.status

  const log_string = "handling job " + job.id + " step " + job.current_step_id + " sequence " + job.current_sequence + " status " + status
  console.log(log_string)


  if (status === 'not_started') {
    start_job(job, configuration, handle_job)
    updateJobStatus(job, configuration)
  } else if (status == 'running') {
    run_current_step(job, configuration, handle_job)
    updateJobStatus(job, configuration)
  } else if (status == 'failed') {
    const step = current_step(job)
    updateStepStatus(step, configuration)
    updateJobStatus(job, configuration)
  } else if (status == 'complete') {
    const step = current_step(job)
    updateStepStatus(step, configuration)
    updateJobStatus(job, configuration)
  }
}

function handle_step(job, configuration) {
  const status = job.status
  console.log("Handling Step")
  console.log(job)
  if (status === 'not_started') {
    start_job(job, configuration, handle_step)
  } else if (status == 'running') {
    run_current_step(job, configuration, handle_step)
  } else if (status == 'failed') {
    const step = current_step(job)
    updateStepStatus(step, configuration)
  } else if (status == 'complete') {
    const step = current_step(job)
    updateStepStatus(step, configuration)
  }
}

function start_job(job, configuration, proceed) {
  const steps = job.process.steps

  const log_string = "Starting Job"
  console.log(log_string)

  job.status = 'running'
  job.current_step_id = steps[0].id
  job.current_sequence = 1

  proceed(job, configuration)
}

function run_current_step(job, configuration, proceed) {
  var step = current_step(job)
  var apply = current_sequence(job, step)

  apply(job, configuration, proceed)
}

function current_step(job) {
  const steps = job.process.steps
  return steps.filter(step => step.id === job.current_step_id)[0]
}

function current_step_index(job) {
  const steps = job.process.steps
  return steps.findIndex(step => step.id === job.current_step_id)
}

function current_sequence(job, step) {
  const log_string = "Locating current sequence of " + step.step_type.name
  console.log(log_string)
  const step_type_name = step.step_type.name
  const sequence_id = job.current_sequence

  return commands()[step_type_name][sequence_id]
}

function success(job, configuration, proceed) { 
  console.log("Step Succeeded")
  job.current_sequence = job.current_sequence + 1
  proceed(job, configuration)
}

function updateStepStatus(step, configuration) {
  // # TODO: Remove this convention and replace with something I pass in
  console.log("Updating step status")
  const step_element_id = "step-" + step.id + "-runner"
  var step_element = document.getElementById(step_element_id)
  
  // TODO: Refactor based on environment
  if(configuration.environment == 'extenstion') {
    step.element_id = step_element_id
    step_element.dispatchEvent(new CustomEvent("message", {
      bubbles: false,
      detail: step
    }))
  }
}

function updateJobStatus(job, configuration) {
  // # TODO: Remove this convention and replace with something I pass in
  console.log("Updating Job Status")
  const job_element_id = "process-" + job.process.id + "-runner"
  var job_element = document.getElementById(job_element_id)

  chrome.storage.local.set({job: job}, function() {});

  if(configuration.environment == 'extenstion') {
    job.element_id = job_element_id
    job_element.dispatchEvent(new CustomEvent("message", {
      bubbles: false,
      detail: job
    }))
  }
}

function failStep(job, error, configuration, proceed) {
  console.log("Step Failed")
  console.log(error)
  var step = current_step(job)
  step.status = "failed"
  step.error = error

  if(configuration.environment == 'extension') {
    console.log("In Extension")
    failJob(job, "Step " + step.id + " failed", configuration, proceed)
  } else if (configuration.environment == 'browser') {
    console.log("In Browser")
    failJob(job, "Step " + step.id + " failed", configuration, proceed)
  }

}

function failJob(job, error, configuration, proceed) {
  console.log("Job Failed")
  job.status = "failed"
  job.error = error

  if(configuration.environment == 'extension') {
    proceed(job, configuration)
  } else if (configuration.environment == 'browser') {
    chrome.runtime.sendMessage(job)
  }
}

function commands() {
  return {
    "Click": {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: click,
      5: sendToExtension,
      6: completeStep
    },
    "Navigate": {
      1: startStep,
      2: navigate,
      3: waitForLoad,
      4: completeStep
    },
    "Fill Field": {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: fillField,
      5: sendToExtension,
      6: completeStep
    },
    "Set Size Explicit": {
      1: startStep,
      2: setSize,
      3: completeStep
    },
    "Full Screen Screenshot": {
      1: startStep,
      2: fullScreenShot,
      3: completeStep
    },
    "Element Screenshot": {
      1: startStep,
      2: sendToBrowser,
      3: collectElementDimensions,
      4: sendToExtension,
      5: fullScreenShot,
      6: completeStep
    },
    "Apply Annotation": {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: applyAnnotation,
      5: sendToExtension,
      6: completeStep
    },
    "Clear Annotations": {
      1: startStep,
      2: sendToBrowser,
      3: clearAnnotations,
      4: sendToExtension,
      5: completeStep
    },
    "Set Selector": {
      1: sendToExtension,
      2: setSelector,
      3: completeStep
    },
    "Test Selector": {
      1: sendToBrowser,
      2: testSelector,
      3: completeStep
    }
  }
}

function collectElementDimensions(job, configuration, proceed) {
  const step = current_step(job)
  const step_index = current_step_index(job)

  const selector = step.element.selector
  const strategy = step.element.strategy
  const element = getElement(strategy, selector)

  step.element.size = element.getBoundingClientRect()
  job.process.steps[step_index] = step
  
  success(job, configuration, proceed)
}

function annotations() {
  return {
    "Outline": outline,
    "Badge": badge
  }
}

function clearAnnotations(job, configuration, proceed) {
  const step = current_step(job)

  try {
    for (let i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }
    window.active_annotations = []
    success(job, configuration, proceed)
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function applyAnnotation(job, configuration, proceed) {
  const step = current_step(job)
  const name = step.annotation.annotation_type.name
  console.log("applying annotation")
  /*
  console.log(step)
  console.log(step.annotation.annotation_type.name)
  console.log(annotations())
  */
  var apply = annotations()[name]
  try {
    apply(job, configuration, proceed)
    success(job, configuration, proceed)
  } catch(error) {
    failStep(job, error, configuration, proceed)
  }
}

function blur(job, configuration) {

}

function badge(job, configuration, proceed) {
  console.log("Applying badge annotation")
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  const element = getElement(strategy, selector)

  var badge_x = step.annotation.x_orientation
  var badge_y = step.annotation.y_orientation
  var size = step.annotation.size
  var labelText = step.annotation.label
  var color = step.annotation.color
  var xOffset = step.annotation.x_offset
  var yOffset = step.annotation.y_offset
  var fontSize = step.annotation.font_size;

  var wrapper = document.createElement('div');
  var badge = document.createElement('span');
  var label = document.createElement('span');

  const rect = element.getBoundingClientRect();

  const x_calcs = {
    L: Math.round(rect.left - size + xOffset).toString() + 'px',
    M: Math.round(rect.left + rect.width/2 - size + xOffset).toString() + 'px',
    R: Math.round(rect.right - size + xOffset).toString() + 'px'
  }
  const y_calcs = {
    T: Math.round(rect.top - size + yOffset).toString() + 'px',
    M: Math.round(rect.bottom - rect.height/2 - size + yOffset).toString() + 'px',
    B: Math.round(rect.bottom - size + yOffset).toString() + 'px'
  }

  const x = x_calcs[badge_x]
  const y = y_calcs[badge_y]

  console.log("Placing a badge at " + x.toString() + ", " + y.toString())

  wrapper.style.display = 'static';
  wrapper.style.justifyContent = 'center';
  wrapper.style.alignItems = 'center';
  wrapper.style.minHeight = '';
  wrapper.style.position = 'fixed';
  wrapper.style.top = y;
  wrapper.style.left = x;
  wrapper.style.zIndex = 999999;

  badge.style.position = 'relative';
  badge.style.display = 'inline-table';
  badge.style.width = (2 * size).toString() + 'px';
  badge.style.height = (2 * size).toString() + 'px';
  badge.style.borderRadius = '50%';
  badge.style.fontSize = fontSize.toString() + 'px';
  badge.style.textAlign = 'center';
  badge.style.background = color;

  label.style.position = 'relative';
  label.style.top = ((size * 2 - fontSize) / 2).toString() + 'px';
  label.textContent = labelText;
  label.style.color = 'white';

  try {
    document.body.appendChild(wrapper);
    wrapper.appendChild(badge); 
    badge.appendChild(label);
    window.active_annotations.push(wrapper);
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function outline(job, configuration, proceed) {
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  const outlineColor = step.annotation.color
  const thickness = step.annotation.thickness + 'px';

  const element = getElement(strategy, selector)

  const rect = element.getBoundingClientRect();
  const outline = document.createElement('div');
  
  outline.style.position = 'fixed';
  outline.style.width = Math.round(rect.width).toString() + 'px'
  outline.style.height = Math.round(rect.height).toString() + 'px'
  outline.style.outline = outlineColor + ' solid ' + thickness;
  outline.style.top = Math.round(rect.top).toString() + 'px';
  outline.style.left = Math.round(rect.left).toString() + 'px';
  outline.style.zIndex = 99999;

  try {
    document.body.appendChild(outline)
    window.active_annotations.push(outline)
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function fullScreenShot(job, configuration, proceed) {
  const activeWindowId = job.activeWindowId
  const step = current_step(job)

  console.log("Taking a full screen screenshot")
  try {
    chrome.tabs.captureVisibleTab(activeWindowId, function(result) {
      console.log("Finished capturing Result")
      console.log(result)
      if(result) {
        step.encoded_image = result
        document
          .getElementById("screenshot-handler-component")
          .dispatchEvent(new CustomEvent("message", {
            bubbles: false,
            detail: step
          }))
        success(job, configuration, proceed)
      } else if(result == undefined) {
        step.status = "failed"
        const error = "No Screenshot Returned"
        step.error = error
        failStep(job, error, configuration, proceed)
      }
    })
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function setSize(job, configuration, proceed) {
  const activeWindowId = job.activeWindowId
  const step = current_step(job)
  const payload = {
    width: step.width,
    height: step.height
  }

  console.log("Setting size in " + activeWindowId)
  console.log(payload)

  try {
    chrome.windows.update(activeWindowId, payload)
    success(job, configuration, proceed)
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }

}

function navigate(job, configuration, proceed) {
  const activeTabId = job.activeTabId
  const step = current_step(job)

  var payload = {}

  if (step.page_reference == "page") {
    payload.url = step.page.url
  } else {
    payload.url = step.url
  }


  const log_string = "Executing a navigate step to " + activeTabId
  
  try {
    chrome.tabs.update(activeTabId, payload, function(result) {
      console.log("Triggered Navigation")
      success(job, configuration, proceed)
    })
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function fillField(job, configuration, proceed) {
  console.log("Filling a field")
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  const text = step.text
  const element = getElement(strategy, selector)
  const event = new Event('input', { bubbles: true })

  try {
    console.log("Writing to field")  
    element.value = text
    element.dispatchEvent(event)
    success(job, configuration, proceed)
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function waitForLoad(job, configuration, proceed) {
  console.log("waiting for load")
  const activeTabId = job.activeTabId

  var timeout = setTimeout(function(){ 
    clearInterval(interval)
    console.log("Not found")
    failStep(job, "Page not Loaded", configuration, proceed)
   }, 3000);

  var interval = setInterval(function(){
    chrome.tabs.get(activeTabId, function(r) {
      if(r.status == 'complete') {
        clearTimeout(timeout)
        clearInterval(interval)
        console.log("Page Loaded")
        success(job, configuration, proceed)
      }
    })
  }, 100);
}


function startStep(job, configuration, proceed) {
  var step = current_step(job)
  // TODO: This is a convention.  Find a cleaner way to pass from backend
  const step_element_id = "step-" + step.id + "-runner"
  const step_element = document.getElementById(step_element_id)
  const step_index = current_step_index(job)
  const steps = job.process.steps

  console.log(step)
  console.log("Starting a " + step.step_type.name + " step")

  step.status = "running"
  step.element_id = step_element_id

  if(configuration.environment == 'extension') {
    step_element.dispatchEvent(new CustomEvent("message", {
      bubbles: false,
      detail: step
    }))
  }

  try {
    steps[step_index] = step
    success(job, configuration, proceed)
  } catch(error) {
    failStep(job, error, configuration, proceed)
  }
}

function completeStep(job, configuration, proceed) {
  var step = current_step(job)
  const step_index = current_step_index(job)
  // TODO: This is a convention.  Find a cleaner way to pass from backend
  const step_element_id = "step-" + step.id + "-runner"
  const step_element = document.getElementById(step_element_id)
  const event = new CustomEvent("message", {bubbles: false, detail: step})
  const steps = job.process.steps

  const log_string = "Completing step " + step_element_id
  console.log(log_string)

  step.status = "complete"
  // TODO: Fix based on environment
  try {
    if (step_element != null) { step_element.dispatchEvent(event) }
    var next_step = steps[step_index + 1]
    console.log(next_step)
    if (next_step) {
      // If there's another step, we update and call handle_job
      job.current_step_id = next_step.id
      job.current_sequence = 1
      proceed(job, configuration)
    } else {
      // If there's not, we're going to complete the job
      completeJob(job, configuration, proceed)
    }
  } catch(error) {
    failStep(job, error, configuration, proceed)
  }
}

function completeJob(job, configuration, proceed) {
  job.status = 'complete'
  proceed(job, configuration)
}


function sendToBrowser(job, configuration, proceed) {
  console.log("Send to browser")
  if(configuration.environment == 'extension') {
    console.log("Sending to browser")
    // console.log(job.activeTabId)
    const message = {
      type: job.type,
      payload: job
    }
    try {
      job.current_sequence = job.current_sequence + 1
      chrome.tabs.sendMessage(job.activeTabId, message)
      console.log("Step sent to browser")
    } catch(error) {
      failStep(job, error, configuration, proceed)
    }
  } else {
    success(job, configuration, proceed)
  }
}

function sendToExtension(job, configuration, proceed) {
  console.log("Send to extension")
  if(configuration.environment == 'browser') {
    console.log("sending to browser")
    const message = {
      type: job.type,
      payload: job
    }

    try {
      job.current_sequence = job.current_sequence + 1
      chrome.runtime.sendMessage(message)
      console.log("Sent to Extension") 
    } catch(error) {
      failStep(job, error, configuration, proceed)
    } 
  } else {
    success(job, configuration, proceed)
  }
}

function waitForElement(job, configuration, proceed) {
  var step = current_step(job)

  const selector = step.element.selector
  const strategy = step.element.strategy

  console.log(strategy)

  var element = null
  
  const log_string = "Waiting for element, strategy: " + strategy.name + " selector: " + selector
  console.log(log_string)

  var timeout = setTimeout(function(){ 
    clearInterval(interval)
    failStep(job, "Element not found", configuration, proceed)
   }, 3000);
  var interval = setInterval(function(){
    element = getElement(strategy, selector)
    if(element) {
      step.status = "running_prechecks"
      clearTimeout(timeout)
      clearInterval(interval)
      console.log(element)
      console.log("found")
      success(job, configuration, proceed)
    }
  }, 100);
}

function click(job, configuration, proceed) {
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy

  try {
    console.log("Getting element")
    getElement(strategy, selector)
      .click()
    success(job, configuration, proceed)
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, configuration, proceed)
  }
}

function getElement(strategy, selector) {
  console.log("Getting Element with strategy " + strategy.name + " and Selector " + selector)
  var element = null

  if(strategy.name == 'xpath') {
    element = document.evaluate(
      selector, 
      document, 
      null, 
      XPathResult.FIRST_ORDERED_NODE_TYPE, 
      null).singleNodeValue
  } else if (strategy.name == 'id') {
    element = document.getElementById(selector)
  } else if (strategy.name == 'css') {
    element = document.querySelector(selector)
  }
  console.log(element)
  return element
}

function getSelector(job, configuration, proceed) {
  console.log("Getting Selector")
  success(job, configuration, proceed)
}

function setSelector(job, configuration, proceed) {
  const step = current_step(job)

  const payload = {
    selector: step.selector,
    strategy: step.strategy
  }

  console.log("Setting Strategy to " + payload.strategy + " and Selector to " + payload.selector)

  document
    .getElementById("selector-handler")
    .dispatchEvent(new CustomEvent("selector", {
      bubbles: false,
      detail: payload
    }))

  success(job, configuration, proceed)
}

function testSelector(job, configuration, proceed) {
  const step = current_step(job)
  const selector = step.selector
  const strategy = step.strategy
  console.log("22 Testing " + strategy + " Selector " + selector)
  console.log(step)

  if (strategy.name === 'xpath') {
    console.log("xpath")

    document
      .evaluate(selector, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
      .singleNodeValue
      .style
      .backgroundColor = "#FDFF47"

  } else if (strategy.name === 'css') {

    document
      .querySelector(selector)
      .style
      .backgroundColor = "#FDFF47"
  }
}

export {handle_job, handle_message}