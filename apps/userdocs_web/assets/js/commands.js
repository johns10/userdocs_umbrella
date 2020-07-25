function handle_job(job, environment) {
  console.log("handling job " + job.id + " step " + job.current_step_id + " sequence " + job.current_sequence)
  console.log(job)
  console.log(job.active_annotations[0])
  if (job.status === 'not_started') {
    start_job(job, environment)
    updateJobStatus(job)
  } else if (job.status == 'running') {
    run_current_step(job, environment)
  } else if (job.status == 'failed') {
    const step = current_step(job)
    updateStepStatus(step)
    updateJobStatus(job)
  } else if (job.status == 'complete') {
    const step = current_step(job)
    updateStepStatus(step)
    updateJobStatus(job)
  }
}

function start_job(job, environment) {
  console.log("Starting Job")
  // console.log(job)
  job.status = 'running'
  job.current_step_id = job.steps[0].id
  job.current_sequence = 1

  handle_job(job, environment)
}

function run_current_step(job, environment) {
  var step = current_step(job)
  var apply = current_sequence(job, step)

  apply(job, environment)
}

function current_step(job) {
  // console.log("Locating current step")
  // console.log(job)
  return job.steps.filter(step => step.id === job.current_step_id)[0]
}

function current_step_index(job) {
  return job.steps.findIndex(step => step.id === job.current_step_id)
}

function current_sequence(job, step) {
  // console.log("Locating current sequence")
  var sequence_id = job.current_sequence
  return commands()[step.type][sequence_id]
}

function success(job, environment) { 
  console.log("Step Succeeded")
  job.current_sequence = job.current_sequence + 1
  handle_job(job, environment)
}

function updateStepStatus(step) {
  var step_element = document.getElementById(step.element_id)
  step_element.dispatchEvent(new CustomEvent("message", {
    bubbles: false,
    detail: step
  }))
}

function updateJobStatus(job) {
  var job_element = document.getElementById(job.element_id)
  job_element.dispatchEvent(new CustomEvent("message", {
    bubbles: false,
    detail: job
  }))
}

function failStep(job, error, environment) {
  console.log("Step Failed")
  console.log(error)
  var step = current_step(job)
  step.status = "failed"
  step.error = error

  if(environment == 'extension') {
    console.log("In Extension")
    updateStepStatus(step)
    failJob(job, "Step " + step.id + " failed", environment)
  } else if (environment == 'browser') {
    console.log("In Browser")
    failJob(job, "Step " + step.id + " failed", environment)
  }

}

function failJob(job, error, environment) {
  console.log("Job Failed")
  job.status = "failed"
  job.error = error

  if(environment == 'extension') {
    updateJobStatus(job)
  } else if (environment == 'browser') {
    chrome.runtime.sendMessage(job)
  }
}

function commands() {
  return {
    click: {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: click,
      5: sendToExtension,
      6: completeStep
    },
    navigate: {
      1: startStep,
      2: navigate,
      3: waitForLoad,
      4: completeStep
    },
    fill_field: {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: fillField,
      5: sendToExtension,
      6: completeStep
    },
    set_size_explicit: {
      1: startStep,
      2: setSize,
      3: completeStep
    },
    full_screen_screenshot: {
      1: startStep,
      2: fullScreenShot,
      3: completeStep
    },
    apply_annotation: {
      1: startStep,
      2: sendToBrowser,
      3: waitForElement,
      4: applyAnnotation,
      5: sendToExtension,
      6: completeStep
    },
    clear_annotations: {
      1: startStep,
      2: sendToBrowser,
      3: clearAnnotations,
      4: sendToExtension,
      5: completeStep
    }
  }
}

function annotations() {
  return {
    outline: outline,
    badge: badge
  }
}

function clearAnnotations(job, environment) {
  const step = current_step(job)

  try {
    for (let i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }
    window.active_annotations = []
    success(job, environment)
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }
}

function applyAnnotation(job, environment) {
  const step = current_step(job)
  console.log("applying annotation")
  /*
  console.log(step)
  console.log(step.annotation.annotation_type.name)
  console.log(annotations())
  */
  var apply = annotations()[step.annotation.annotation_type.name]
  try {
    apply(job, environment)
    success(job, environment)
  } catch(error) {
    failStep(job, environment)
  }
}

function blur(job, environment) {

}

function badge(job, environment) {
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
  var fontSize = 25;

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
    failStep(job, error, environment)
  }
}

function outline(job, environment) {
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  const element = getElement(strategy, selector)
  const outlineColor = step.annotation.color
  const thickness = step.annotation.thickness + 'px';

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
    failStep(job, error, environment)
  }
}

function fullScreenShot(job, environment) {
  const activeWindowId = job.activeWindowId
  const step = current_step(job)

  console.log("Taking a full screen screenshot")
  try {
    chrome.tabs.captureVisibleTab(activeWindowId, function(result) {
      console.log(result)
      step.encoded_image = result
      document
        .getElementById("screenshot-handler-component")
        .dispatchEvent(new CustomEvent("message", {
          bubbles: false,
          detail: step
        }))
      success(job,environment)
    })
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }
}

function setSize(job, environment) {
  const activeWindowId = job.activeWindowId
  const step = current_step(job)
  const payload = {
    width: step.args.width,
    height: step.args.height
  }

  console.log("Setting size in " + activeWindowId)
  console.log(payload)

  try {
    chrome.windows.update(activeWindowId, payload)
    success(job, environment)
  } catch(error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }

}

function navigate(job, environment) {
  const activeTabId = job.activeTabId
  const step = current_step(job)

  const payload = {
    url: step.args.url
  }

  console.log("Executing a navigate")
  // console.log(activeTabId)
  // console.log(payload)
  
  try {
    chrome.tabs.update(activeTabId, payload, function(result) {
      console.log("Triggered Navigation")
      success(job, environment)
    })
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }
}

function fillField(job, environment) {
  console.log("Filling a field")
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  const text = step.args.text
  const element = getElement(strategy, selector)
  const event = new Event('input', { bubbles: true })

  try {
    console.log("Writing to field")  
    element.value = text
    element.dispatchEvent(event)
    success(job, environment)
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }
}

function waitForLoad(job, environment) {
  console.log("waiting for load")
  const activeTabId = job.activeTabId

  var timeout = setTimeout(function(){ 
    clearInterval(interval)
    console.log("Not found")
    failStep(job, "Page not Loaded", environment)
   }, 3000);

  var interval = setInterval(function(){
    chrome.tabs.get(activeTabId, function(r) {
      if(r.status == 'complete') {
        clearTimeout(timeout)
        clearInterval(interval)
        console.log("Page Loaded")
        success(job, environment)
      }
    })
  }, 100);
}


function startStep(job, environment) {
  console.log("Starting a step")
  var step = current_step(job)
  var step_index = current_step_index(job)
  var step_element = document.getElementById(step.element_id)
  step.status = "running"

  try {
    step_element.dispatchEvent(new CustomEvent("message", {
      bubbles: false,
      detail: step
    }))
    job.steps[step_index] = step
    success(job, environment)
  } catch(error) {
    failStep(job, error, environment)
  }
}

function completeStep(job, environment) {
  console.log("Completing a step")
  var step = current_step(job)
  console.log(step.element_id)
  var step_index = current_step_index(job)
  const step_element = document.getElementById(step.element_id)
  console.log(step_element)
  const event = new CustomEvent("message", {bubbles: false, detail: step})
  step.status = "complete"

  try {
    step_element.dispatchEvent(event)
    var next_step = job.steps[step_index + 1]
    console.log(next_step)
    if (next_step) {
      // If there's another step, we update and call handle_job
      job.current_step_id = next_step.id
      job.current_sequence = 1
      handle_job(job, environment)
    } else {
      // If there's not, we're going to complete the job
      completeJob(job, environment)
    }
  } catch(error) {
    failStep(job, error, environment)
  }
}

function completeJob(job, environment) {
  job.status = 'complete'
  handle_job(job, environment)
}


function sendToBrowser(job, environment) {
  console.log("Send to browser")
  if(environment == 'extension') {
    console.log("Sending to browser")
    // console.log(job.activeTabId)
    try {
      job.current_sequence = job.current_sequence + 1
      chrome.tabs.sendMessage(job.activeTabId, job)
      console.log("Step sent to browser")
    } catch(error) {
      failStep(job, error, environment)
    }
  } else {
    success(job, environment)
  }
}

function sendToExtension(job, environment) {
  if(environment == 'browser') {
    try {
      job.current_sequence = job.current_sequence + 1
      chrome.runtime.sendMessage(job)
      console.log("Sent to Extension") 
    } catch(error) {
      failStep(job, error, environment)
    } 
  } else {
    success(job, environment)
  }
}

function waitForElement(job, environment) {
  var step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy
  var element = null
  // console.log("Waiting for element, strategy: " + strategy + " selector: " + selector)

  var timeout = setTimeout(function(){ 
    clearInterval(interval)
    failStep(job, "Element not found", environment)
   }, 3000);
  var interval = setInterval(function(){
    element = getElement(strategy, selector)
    if(element) {
      step.status = "running_prechecks"
      clearTimeout(timeout)
      clearInterval(interval)
      console.log("found")
      success(job, environment)
    }
  }, 100);
}

function click(job, environment) {
  const step = current_step(job)
  const selector = step.element.selector
  const strategy = step.element.strategy

  try {
    console.log("Getting element")
    getElement(strategy, selector)
      .click()
    success(job, environment)
  } catch (error) {
    step.status = "failed"
    step.error = error
    failStep(job, error, environment)
  }
}

function getElement(strategy, selector) {
  var element = null

  if(strategy == 'xpath') {
    element = document.evaluate(
      selector, 
      document, 
      null, 
      XPathResult.FIRST_ORDERED_NODE_TYPE, 
      null).singleNodeValue
  } else if (strategy == 'id') {
    element = document.getElementById(selector)
  }
  return element
}

export {handle_job}