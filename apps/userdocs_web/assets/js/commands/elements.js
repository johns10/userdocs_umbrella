async function waitForElement(stepInstance) {
  const timeout = 200
  const interval = 100
  const selector = stepInstance.attrs.element.selector
  const strategy = stepInstance.attrs.element.strategy
  var element = null
  var error = null
  const log_string = "Waiting for element, strategy: " + strategy.name + " selector: " + selector

  for(i = 0; i < timeout / interval; i ++) {
    try {
      element = window.userdocs.getElement(strategy, selector)
      return stepInstance
    } catch(e) {
      error = e
    }
    await new Promise(resolve => setTimeout(resolve, interval));
  }

  console.log("Fixing to throw")
  throw(error)
}


function getElement(strategy, selector) {
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
  if (element == null) { 
    console.log("Element is null")
    throw new window.userdocs.ElementNotFound(strategy, selector) 
  } else { 
    return element 
  }
}

function elementSize(step) {
  const selector = step.attrs.element.selector;
  const strategy = step.attrs.element.strategy;
  const element = window.userdocs.getElement(strategy, selector);
  const rect = element.getBoundingClientRect()
  return {
    bottom: rect.bottom,
    height: rect.height,
    left: rect.left,
    right: rect.right,
    top: rect.top,
    width: rect.width,
    x: rect.x,
    y: rect.y
  }
}

class ElementNotFound extends Error {
  constructor(strategy, selector, ...params) {
    super(...params)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, ElementNotFound)
    }

    this.name = 'ElementNotFound'
    this.message = 'Failed to find ' + selector + ' using ' + strategy.name
  }
}

  
module.exports.waitForElement = waitForElement;
module.exports.elementSize = elementSize;
module.exports.getElement = getElement;
module.exports.ElementNotFound = ElementNotFound;