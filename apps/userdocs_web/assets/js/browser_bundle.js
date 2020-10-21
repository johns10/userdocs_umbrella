/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/js/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./js/browser.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./js/browser.js":
/*!***********************!*\
  !*** ./js/browser.js ***!
  \***********************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _browser_main_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./browser_main.js */ "./js/browser_main.js");

Object(_browser_main_js__WEBPACK_IMPORTED_MODULE_0__["main"])();

/***/ }),

/***/ "./js/browser_main.js":
/*!****************************!*\
  !*** ./js/browser_main.js ***!
  \****************************/
/*! exports provided: main */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "main", function() { return main; });
/* harmony import */ var css_selector_generator__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! css-selector-generator */ "./node_modules/css-selector-generator/build/index.js");
/* harmony import */ var css_selector_generator__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(css_selector_generator__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _commands_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./commands.js */ "./js/commands.js");


var getCssSelectorOptions = {
  selectors: ["class", "tag", "attribute", "nthchild"]
};
var XPATH = null;
var CSSS = null;
var XPATH_STRATEGY_TYPE = 1;
var CSS_STRATEGY_TYPE = 2;

function main() {
  console.log("Initializing Browser stuff");
  window.active_annotations = [];
  chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    var logSuffix = sender.tab ? "from a content script:" + sender.tab.url : "from the extension";
    console.log("Browser received message " + logSuffix);
    Object(_commands_js__WEBPACK_IMPORTED_MODULE_1__["handle_message"])(request, {
      environment: 'browser'
    });
  });

  document.onmouseover = function (event) {
    var el = event.target;
    console.log(el);
    console.log(css_selector_generator__WEBPACK_IMPORTED_MODULE_0___default()(el, getCssSelectorOptions));
    CSSS = css_selector_generator__WEBPACK_IMPORTED_MODULE_0___default()(el, getCssSelectorOptions);
    XPATH = getPathTo(event.target);
  };

  document.onkeydown = function (event) {
    var x = event.keyCode;

    if (x === 67) {
      chrome.storage.local.get(['strategy'], function (result) {
        console.log("Retreived configuration value");
        console.log(result.strategy);
        var selector;
        var configuration = {
          environment: 'browser',
          strategy: result.strategy
        };

        if (result.strategy.name === 'xpath') {
          selector = XPATH;
        } else if (result.strategy.name === 'css') {
          selector = CSSS;
        }

        var message = {
          type: 'step',
          payload: {
            id: 0,
            status: 'not_started',
            process: {
              steps: [{
                id: 0,
                selector: selector,
                strategy: result.strategy,
                step_type: {
                  name: "Set Selector"
                }
              }]
            }
          }
        };
        Object(_commands_js__WEBPACK_IMPORTED_MODULE_1__["handle_message"])(message, configuration);
      });
    }
  };
}

function getPathTo(element) {
  if (element === document.body) return element.tagName.toLowerCase();
  var ix = 0;
  var siblings = element.parentNode.childNodes;

  for (var i = 0; i < siblings.length; i++) {
    var sibling = siblings[i];
    if (sibling === element) return getPathTo(element.parentNode) + '/' + element.tagName.toLowerCase() + '[' + (ix + 1) + ']';

    if (sibling.nodeType === 1 && sibling.tagName === element.tagName) {
      ix++;
    }
  }
}



/***/ }),

/***/ "./js/commands.js":
/*!************************!*\
  !*** ./js/commands.js ***!
  \************************/
/*! exports provided: handle_message */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "handle_message", function() { return handle_message; });
/* harmony import */ var nprogress__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! nprogress */ "./node_modules/nprogress/nprogress.js");
/* harmony import */ var nprogress__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(nprogress__WEBPACK_IMPORTED_MODULE_0__);


function handle_message(message, configuration) {
  var log_string = "Received " + message.type + " message.  ";
  console.log(log_string);

  if (message.type == 'process') {
    message.payload.type = 'process';
    handle_job(message.payload, configuration);
  } else if (message.type == 'step') {
    message.payload.type = 'step';
    handle_step(message.payload, configuration);
  } else if (message.type == 'configuration') {
    configure_environment(message.payload);
  }
}

function configure_environment(payload) {
  console.log("Current Configuration");
  chrome.storage.local.set({
    strategy: payload.strategy
  }, function () {
    console.log('Selector Strategy is set to ' + payload.strategy.name);
  });
}

function handle_job(job, configuration) {
  var status = job.status;
  var log_string = "handling job " + job.id + " step " + job.current_step_id + " sequence " + job.current_sequence + " status " + status;
  console.log(log_string);

  if (status === 'not_started') {
    start_job(job, configuration, handle_job);
    updateJobStatus(job);
  } else if (status == 'running') {
    run_current_step(job, configuration, handle_job);
  } else if (status == 'failed') {
    var step = current_step(job);
    updateStepStatus(step);
    updateJobStatus(job);
  } else if (status == 'complete') {
    var _step = current_step(job);

    updateStepStatus(_step);
    updateJobStatus(job);
  }
}

function handle_step(job, configuration) {
  var status = job.status;
  console.log("Handling Step");
  console.log(job);

  if (status === 'not_started') {
    start_job(job, configuration, handle_step);
  } else if (status == 'running') {
    run_current_step(job, configuration, handle_step);
  } else if (status == 'failed') {
    var step = current_step(job);
    updateStepStatus(step);
  } else if (status == 'complete') {
    var _step2 = current_step(job);

    updateStepStatus(_step2);
  }
}

function start_job(job, configuration, proceed) {
  var steps = job.process.steps;
  var log_string = "Starting Job";
  console.log(log_string);
  job.status = 'running';
  job.current_step_id = steps[0].id;
  job.current_sequence = 1;
  proceed(job, configuration);
}

function run_current_step(job, configuration, proceed) {
  var step = current_step(job);
  var apply = current_sequence(job, step);
  apply(job, configuration, proceed);
}

function current_step(job) {
  var steps = job.process.steps;
  return steps.filter(function (step) {
    return step.id === job.current_step_id;
  })[0];
}

function current_step_index(job) {
  var steps = job.process.steps;
  return steps.findIndex(function (step) {
    return step.id === job.current_step_id;
  });
}

function current_sequence(job, step) {
  var log_string = "Locating current sequence of " + step.step_type.name;
  console.log(step);
  var step_type_name = step.step_type.name;
  var sequence_id = job.current_sequence;
  return commands()[step_type_name][sequence_id];
}

function success(job, configuration, proceed) {
  console.log("Step Succeeded");
  job.current_sequence = job.current_sequence + 1;
  proceed(job, configuration);
}

function updateStepStatus(step) {
  // # TODO: Remove this convention and replace with something I pass in
  console.log("Updating step status");
  var step_element_id = "step-" + step.id + "-runner";
  var step_element = document.getElementById(step_element_id);
  step.element_id = step_element_id;
  console.log(step);
  step_element.dispatchEvent(new CustomEvent("message", {
    bubbles: false,
    detail: step
  }));
}

function updateJobStatus(job) {
  // # TODO: Remove this convention and replace with something I pass in
  console.log("Updating Job Status");
  var job_element_id = "process-" + job.process.id + "-runner";
  var job_element = document.getElementById(job_element_id);
  job.element_id = job_element_id;
  job_element.dispatchEvent(new CustomEvent("message", {
    bubbles: false,
    detail: job
  }));
}

function failStep(job, error, configuration, proceed) {
  console.log("Step Failed");
  console.log(error);
  var step = current_step(job);
  step.status = "failed";
  step.error = error;

  if (configuration.environment == 'extension') {
    console.log("In Extension");
    failJob(job, "Step " + step.id + " failed", configuration, proceed);
  } else if (configuration.environment == 'browser') {
    console.log("In Browser");
    failJob(job, "Step " + step.id + " failed", configuration, proceed);
  }
}

function failJob(job, error, configuration, proceed) {
  console.log("Job Failed");
  job.status = "failed";
  job.error = error;

  if (configuration.environment == 'extension') {
    proceed(job, configuration);
  } else if (configuration.environment == 'browser') {
    chrome.runtime.sendMessage(job);
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
      2: setSelector
    },
    "Test Selector": {
      1: sendToBrowser,
      2: testSelector
    }
  };
}

function collectElementDimensions(job, configuration, proceed) {
  var step = current_step(job);
  var step_index = current_step_index(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;
  var element = getElement(strategy, selector);
  step.element.size = element.getBoundingClientRect();
  job.process.steps[step_index] = step;
  success(job, configuration, proceed);
}

function annotations() {
  return {
    "Outline": outline,
    "Badge": badge
  };
}

function clearAnnotations(job, configuration, proceed) {
  var step = current_step(job);

  try {
    for (var i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }

    window.active_annotations = [];
    success(job, configuration, proceed);
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function applyAnnotation(job, configuration, proceed) {
  var step = current_step(job);
  var name = step.annotation.annotation_type.name;
  console.log("applying annotation");
  /*
  console.log(step)
  console.log(step.annotation.annotation_type.name)
  console.log(annotations())
  */

  var apply = annotations()[name];

  try {
    apply(job, configuration, proceed);
    success(job, configuration, proceed);
  } catch (error) {
    failStep(job, error, configuration, proceed);
  }
}

function blur(job, configuration) {}

function badge(job, configuration, proceed) {
  var step = current_step(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;
  var element = getElement(strategy, selector);
  var badge_x = step.annotation.x_orientation;
  var badge_y = step.annotation.y_orientation;
  var size = step.annotation.size;
  var labelText = step.annotation.label;
  var color = step.annotation.color;
  var xOffset = step.annotation.x_offset;
  var yOffset = step.annotation.y_offset;
  var fontSize = 25;
  var wrapper = document.createElement('div');
  var badge = document.createElement('span');
  var label = document.createElement('span');
  var rect = element.getBoundingClientRect();
  var x_calcs = {
    L: Math.round(rect.left - size + xOffset).toString() + 'px',
    M: Math.round(rect.left + rect.width / 2 - size + xOffset).toString() + 'px',
    R: Math.round(rect.right - size + xOffset).toString() + 'px'
  };
  var y_calcs = {
    T: Math.round(rect.top - size + yOffset).toString() + 'px',
    M: Math.round(rect.bottom - rect.height / 2 - size + yOffset).toString() + 'px',
    B: Math.round(rect.bottom - size + yOffset).toString() + 'px'
  };
  var x = x_calcs[badge_x];
  var y = y_calcs[badge_y];
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
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function outline(job, configuration, proceed) {
  var step = current_step(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;
  var outlineColor = step.annotation.color;
  var thickness = step.annotation.thickness + 'px';
  var element = getElement(strategy, selector);
  var rect = element.getBoundingClientRect();
  var outline = document.createElement('div');
  outline.style.position = 'fixed';
  outline.style.width = Math.round(rect.width).toString() + 'px';
  outline.style.height = Math.round(rect.height).toString() + 'px';
  outline.style.outline = outlineColor + ' solid ' + thickness;
  outline.style.top = Math.round(rect.top).toString() + 'px';
  outline.style.left = Math.round(rect.left).toString() + 'px';
  outline.style.zIndex = 99999;

  try {
    document.body.appendChild(outline);
    window.active_annotations.push(outline);
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function fullScreenShot(job, configuration, proceed) {
  var activeWindowId = job.activeWindowId;
  var step = current_step(job);
  console.log("Taking a full screen screenshot");

  try {
    chrome.tabs.captureVisibleTab(activeWindowId, function (result) {
      console.log("Finished capturing Result");
      console.log(result);

      if (result) {
        step.encoded_image = result;
        document.getElementById("screenshot-handler-component").dispatchEvent(new CustomEvent("message", {
          bubbles: false,
          detail: step
        }));
        success(job, configuration, proceed);
      } else if (result == undefined) {
        step.status = "failed";
        var error = "No Screenshot Returned";
        step.error = error;
        failStep(job, error, configuration, proceed);
      }
    });
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function setSize(job, configuration, proceed) {
  var activeWindowId = job.activeWindowId;
  var step = current_step(job);
  var payload = {
    width: step.width,
    height: step.height
  };
  console.log("Setting size in " + activeWindowId);
  console.log(payload);

  try {
    chrome.windows.update(activeWindowId, payload);
    success(job, configuration, proceed);
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function navigate(job, configuration, proceed) {
  var activeTabId = job.activeTabId;
  var step = current_step(job);
  var payload = {
    url: step.url
  };
  var log_string = "Executing a navigate step to " + activeTabId;
  console.log(log_string);

  try {
    chrome.tabs.update(activeTabId, payload, function (result) {
      console.log("Triggered Navigation");
      success(job, configuration, proceed);
    });
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function fillField(job, configuration, proceed) {
  console.log("Filling a field");
  var step = current_step(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;
  var text = step.text;
  var element = getElement(strategy, selector);
  var event = new Event('input', {
    bubbles: true
  });

  try {
    console.log("Writing to field");
    element.value = text;
    element.dispatchEvent(event);
    success(job, configuration, proceed);
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function waitForLoad(job, configuration, proceed) {
  console.log("waiting for load");
  var activeTabId = job.activeTabId;
  var timeout = setTimeout(function () {
    clearInterval(interval);
    console.log("Not found");
    failStep(job, "Page not Loaded", configuration, proceed);
  }, 3000);
  var interval = setInterval(function () {
    chrome.tabs.get(activeTabId, function (r) {
      if (r.status == 'complete') {
        clearTimeout(timeout);
        clearInterval(interval);
        console.log("Page Loaded");
        success(job, configuration, proceed);
      }
    });
  }, 100);
}

function startStep(job, configuration, proceed) {
  var step = current_step(job); // TODO: This is a convention.  Find a cleaner way to pass from backend

  var step_element_id = "step-" + step.id + "-runner";
  var step_element = document.getElementById(step_element_id);
  var step_index = current_step_index(job);
  var steps = job.process.steps;
  console.log("Starting a " + step.type + " step");
  step.status = "running";
  step.element_id = step_element_id;

  try {
    step_element.dispatchEvent(new CustomEvent("message", {
      bubbles: false,
      detail: step
    }));
    steps[step_index] = step;
    success(job, configuration, proceed);
  } catch (error) {
    failStep(job, error, configuration, proceed);
  }
}

function completeStep(job, configuration, proceed) {
  var step = current_step(job);
  var step_index = current_step_index(job); // TODO: This is a convention.  Find a cleaner way to pass from backend

  var step_element_id = "step-" + step.id + "-runner";
  var step_element = document.getElementById(step_element_id);
  var event = new CustomEvent("message", {
    bubbles: false,
    detail: step
  });
  var steps = job.process.steps;
  var log_string = "Completing step " + step_element_id;
  console.log(log_string);
  step.status = "complete";

  try {
    step_element.dispatchEvent(event);
    var next_step = steps[step_index + 1];
    console.log(next_step);

    if (next_step) {
      // If there's another step, we update and call handle_job
      job.current_step_id = next_step.id;
      job.current_sequence = 1;
      proceed(job, configuration);
    } else {
      // If there's not, we're going to complete the job
      completeJob(job, configuration, proceed);
    }
  } catch (error) {
    failStep(job, error, configuration, proceed);
  }
}

function completeJob(job, configuration, proceed) {
  job.status = 'complete';
  proceed(job, configuration);
}

function sendToBrowser(job, configuration, proceed) {
  console.log("Send to browser");

  if (configuration.environment == 'extension') {
    console.log("Sending to browser"); // console.log(job.activeTabId)

    var message = {
      type: job.type,
      payload: job
    };

    try {
      job.current_sequence = job.current_sequence + 1;
      chrome.tabs.sendMessage(job.activeTabId, message);
      console.log("Step sent to browser");
    } catch (error) {
      failStep(job, error, configuration, proceed);
    }
  } else {
    success(job, configuration, proceed);
  }
}

function sendToExtension(job, configuration, proceed) {
  console.log("Send to extension");

  if (configuration.environment == 'browser') {
    console.log("sending to browser");
    var message = {
      type: job.type,
      payload: job
    };

    try {
      job.current_sequence = job.current_sequence + 1;
      chrome.runtime.sendMessage(message);
      console.log("Sent to Extension");
    } catch (error) {
      failStep(job, error, configuration, proceed);
    }
  } else {
    success(job, configuration, proceed);
  }
}

function waitForElement(job, configuration, proceed) {
  var step = current_step(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;
  console.log(strategy);
  var element = null;
  var log_string = "Waiting for element, strategy: " + strategy.name + " selector: " + selector;
  console.log(log_string);
  var timeout = setTimeout(function () {
    clearInterval(interval);
    failStep(job, "Element not found", configuration, proceed);
  }, 3000);
  var interval = setInterval(function () {
    element = getElement(strategy, selector);

    if (element) {
      step.status = "running_prechecks";
      clearTimeout(timeout);
      clearInterval(interval);
      console.log("found");
      success(job, configuration, proceed);
    }
  }, 100);
}

function click(job, configuration, proceed) {
  var step = current_step(job);
  var selector = step.element.selector;
  var strategy = step.element.strategy;

  try {
    console.log("Getting element");
    getElement(strategy, selector).click();
    success(job, configuration, proceed);
  } catch (error) {
    step.status = "failed";
    step.error = error;
    failStep(job, error, configuration, proceed);
  }
}

function getElement(strategy, selector) {
  console.log("Getting Element with strategy " + strategy.name + " and Selector " + selector);
  var element = null;

  if (strategy.name == 'xpath') {
    element = document.evaluate(selector, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  } else if (strategy.name == 'id') {
    element = document.getElementById(selector);
  } else if (strategy.name == 'css') {
    element = document.querySelector(selector);
  }

  return element;
}

function getSelector(job, configuration, proceed) {
  console.log("Getting Selector");
  success(job, configuration, proceed);
}

function setSelector(job, configuration, proceed) {
  var step = current_step(job);
  var payload = {
    selector: step.selector,
    strategy: step.strategy
  };
  console.log("Setting Strategy to " + payload.strategy + " and Selector to " + payload.selector);
  document.getElementById("selector-handler").dispatchEvent(new CustomEvent("selector", {
    bubbles: false,
    detail: payload
  }));
  success(job, configuration, proceed);
}

function testSelector(job, configuration, proceed) {
  var step = current_step(job);
  var selector = step.selector;
  var strategy = step.strategy;
  console.log("22 Testing " + strategy + " Selector " + selector);
  console.log(step);

  if (strategy.name === 'xpath') {
    console.log("xpath");
    document.evaluate(selector, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.backgroundColor = "#FDFF47";
  } else if (strategy.name === 'css') {
    document.querySelector(selector).style.backgroundColor = "#FDFF47";
  }
}



/***/ }),

/***/ "./node_modules/css-selector-generator/build/index.js":
/*!************************************************************!*\
  !*** ./node_modules/css-selector-generator/build/index.js ***!
  \************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

!function(t,n){ true?module.exports=n():undefined}(window,(function(){return function(t){var n={};function r(e){if(n[e])return n[e].exports;var o=n[e]={i:e,l:!1,exports:{}};return t[e].call(o.exports,o,o.exports,r),o.l=!0,o.exports}return r.m=t,r.c=n,r.d=function(t,n,e){r.o(t,n)||Object.defineProperty(t,n,{enumerable:!0,get:e})},r.r=function(t){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(t,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(t,"__esModule",{value:!0})},r.t=function(t,n){if(1&n&&(t=r(t)),8&n)return t;if(4&n&&"object"==typeof t&&t&&t.__esModule)return t;var e=Object.create(null);if(r.r(e),Object.defineProperty(e,"default",{enumerable:!0,value:t}),2&n&&"string"!=typeof t)for(var o in t)r.d(e,o,function(n){return t[n]}.bind(null,o));return e},r.n=function(t){var n=t&&t.__esModule?function(){return t.default}:function(){return t};return r.d(n,"a",n),n},r.o=function(t,n){return Object.prototype.hasOwnProperty.call(t,n)},r.p="",r(r.s=2)}([function(t,n,r){var e=r(1);function o(t,n,r){Array.isArray(t)?t.push(n):t[r]=n}t.exports=function(t){var n,r,i,u=[];if(Array.isArray(t))r=[],n=t.length-1;else{if("object"!=typeof t||null===t)throw new TypeError("Expecting an Array or an Object, but `"+(null===t?"null":typeof t)+"` provided.");r={},i=Object.keys(t),n=i.length-1}return function r(c,a){var f,l,s;for(l=i?i[a]:a,Array.isArray(t[l])||(void 0===t[l]?t[l]=[]:t[l]=[t[l]]),f=0;f<t[l].length;f++)p=c,o(s=Array.isArray(p)?[].concat(p):e(p),t[l][f],l),a>=n?u.push(s):r(s,a+1);var p}(r,0),u}},function(t,n){t.exports=function(){for(var t={},n=0;n<arguments.length;n++){var e=arguments[n];for(var o in e)r.call(e,o)&&(t[o]=e[o])}return t};var r=Object.prototype.hasOwnProperty},function(t,n,r){"use strict";r.r(n);var e="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(t){return typeof t}:function(t){return t&&"function"==typeof Symbol&&t.constructor===Symbol?"symbol":typeof t},o=function(t){return null!=t&&"object"===(void 0===t?"undefined":e(t))&&1===t.nodeType&&"object"===e(t.style)&&"object"===e(t.ownerDocument)};function i(t){var n=t.parentNode;if(n)for(var r=0,e=n.childNodes,i=0;i<e.length;i++)if(o(e[i])&&(r+=1,e[i]===t))return[":nth-child(".concat(r,")")];return[]}function u(t){return Object.assign({},c,{root:t.ownerDocument.querySelector(":root")})}var c={selectors:["id","class","tag","attribute"],includeTag:!1,whitelist:[],blacklist:[],combineWithinSelector:!0,combineBetweenSelectors:!0},a=new RegExp(["^$","\\s","^\\d"].join("|")),f=new RegExp(["^$","^\\d"].join("|")),l=["nthoftype","tag","id","class","attribute","nthchild"],s=r(0),p=r.n(s);function d(t){return function(t){if(Array.isArray(t)){for(var n=0,r=new Array(t.length);n<t.length;n++)r[n]=t[n];return r}}(t)||function(t){if(Symbol.iterator in Object(t)||"[object Arguments]"===Object.prototype.toString.call(t))return Array.from(t)}(t)||function(){throw new TypeError("Invalid attempt to spread non-iterable instance")}()}function y(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],n=[[]];return t.forEach((function(t){n.forEach((function(r){n.push(r.concat(t))}))})),n.shift(),n.sort((function(t,n){return t.length-n.length}))}function v(t){return t.replace(/[|\\{}()[\]^$+?.]/g,"\\$&").replace(/\*/g,".+")}function g(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[];if(0===t.length)return new RegExp(".^");var n=t.map((function(t){return"string"==typeof t?v(t):t.source})).join("|");return new RegExp(n)}function h(t,n){var r=arguments.length>2&&void 0!==arguments[2]?arguments[2]:document,e=r.querySelectorAll(n);return 1===e.length&&e[0]===t}function b(t){for(var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:m(t),r=[],e=t;o(e)&&e!==n;)r.push(e),e=e.parentElement;return r}function m(t){return t.ownerDocument.querySelector(":root")}function j(t){return[N(t.tagName.toLowerCase())]}function A(t){return function(t){if(Array.isArray(t)){for(var n=0,r=new Array(t.length);n<t.length;n++)r[n]=t[n];return r}}(t)||function(t){if(Symbol.iterator in Object(t)||"[object Arguments]"===Object.prototype.toString.call(t))return Array.from(t)}(t)||function(){throw new TypeError("Invalid attempt to spread non-iterable instance")}()}var w=g(["class","id","ng-*"]);function S(t){var n=t.nodeName,r=t.nodeValue;return"[".concat(n,"='").concat(N(r),"']")}function O(t){var n=t.nodeName;return!w.test(n)}function x(t){return function(t){if(Array.isArray(t)){for(var n=0,r=new Array(t.length);n<t.length;n++)r[n]=t[n];return r}}(t)||function(t){if(Symbol.iterator in Object(t)||"[object Arguments]"===Object.prototype.toString.call(t))return Array.from(t)}(t)||function(){throw new TypeError("Invalid attempt to spread non-iterable instance")}()}var E=":".charCodeAt(0).toString(16).toUpperCase(),T=/[ !"#$%&'()\[\]{|}<>*+,./;=?@^`~\\]/;function N(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"";return t.split("").map((function(t){return":"===t?"\\".concat(E," "):T.test(t)?"\\".concat(t):escape(t).replace(/%/g,"\\")})).join("")}var C={tag:j,id:function(t){var n=t.getAttribute("id")||"",r="#".concat(N(n));return!a.test(n)&&h(t,r,t.ownerDocument)?[r]:[]},class:function(t){return(t.getAttribute("class")||"").trim().split(/\s+/).filter((function(t){return!f.test(t)})).map((function(t){return".".concat(N(t))}))},attribute:function(t){return A(t.attributes).filter(O).map(S)},nthchild:i,nthoftype:function(t){var n=j(t)[0],r=t.parentElement;if(r)for(var e=r.querySelectorAll(n),o=0;o<e.length;o++)if(e[o]===t)return["".concat(n,":nth-of-type(").concat(o+1,")")];return[]}};function P(t,n){if(t.parentNode)for(var r=function(t,n){return function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},r=n.selectors,e=n.combineBetweenSelectors,o=n.includeTag,i=e?y(r):r.map((function(t){return[t]}));return o?i.map(_):i}(t,n).map((function(n){return r=t,e={},n.forEach((function(t){var n=r[t];n.length>0&&(e[t]=n)})),p()(e).map(q);var r,e})).filter((function(t){return""!==t}))}(function(t,n){var r=n.blacklist,e=n.whitelist,o=n.combineWithinSelector,i=g(r),u=g(e);return function(t){var n=t.selectors,r=t.includeTag,e=[].concat(n);r&&!e.includes("tag")&&e.push("tag");return e}(n).reduce((function(n,r){var e=function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],n=arguments.length>1?arguments[1]:void 0;return t.sort((function(t,r){var e=n.test(t),o=n.test(r);return e&&!o?-1:!e&&o?1:0}))}(function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],n=arguments.length>1?arguments[1]:void 0,r=arguments.length>2?arguments[2]:void 0;return t.filter((function(t){return r.test(t)||!n.test(t)}))}(function(t,n){return(C[n]||function(){return[]})(t)}(t,r),i,u),u);return n[r]=o?y(e):e.map((function(t){return[t]})),n}),{})}(t,n),n),e=(u=r,(c=[]).concat.apply(c,d(u))),o=0;o<e.length;o++){var i=e[o];if(h(t,i,t.parentNode))return i}var u,c;return"*"}function _(t){return t.includes("tag")||t.includes("nthoftype")?x(t):[].concat(x(t),["tag"])}function $(t,n){return n[t]?n[t].join(""):""}function q(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};return l.map((function(n){return $(n,t)})).join("")}function D(t,n){return b(t,n).map((function(t){return i(t)[0]})).reverse().join(" > ")}function M(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};return Object.assign({},u(t),n)}function R(t){for(var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},r=M(t,n),e=b(t,r.root),o=[],i=0;i<e.length;i++){o.unshift(P(e[i],r));var u=o.join(" > ");if(h(t,u,r.root))return u}return D(t,r.root)}r.d(n,"getCssSelector",(function(){return R}));n.default=R}])}));

/***/ }),

/***/ "./node_modules/nprogress/nprogress.js":
/*!*********************************************!*\
  !*** ./node_modules/nprogress/nprogress.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_RESULT__;/* NProgress, (c) 2013, 2014 Rico Sta. Cruz - http://ricostacruz.com/nprogress
 * @license MIT */

;(function(root, factory) {

  if (true) {
    !(__WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.call(exports, __webpack_require__, exports, module)) :
				__WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
  } else {}

})(this, function() {
  var NProgress = {};

  NProgress.version = '0.2.0';

  var Settings = NProgress.settings = {
    minimum: 0.08,
    easing: 'ease',
    positionUsing: '',
    speed: 200,
    trickle: true,
    trickleRate: 0.02,
    trickleSpeed: 800,
    showSpinner: true,
    barSelector: '[role="bar"]',
    spinnerSelector: '[role="spinner"]',
    parent: 'body',
    template: '<div class="bar" role="bar"><div class="peg"></div></div><div class="spinner" role="spinner"><div class="spinner-icon"></div></div>'
  };

  /**
   * Updates configuration.
   *
   *     NProgress.configure({
   *       minimum: 0.1
   *     });
   */
  NProgress.configure = function(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      if (value !== undefined && options.hasOwnProperty(key)) Settings[key] = value;
    }

    return this;
  };

  /**
   * Last number.
   */

  NProgress.status = null;

  /**
   * Sets the progress bar status, where `n` is a number from `0.0` to `1.0`.
   *
   *     NProgress.set(0.4);
   *     NProgress.set(1.0);
   */

  NProgress.set = function(n) {
    var started = NProgress.isStarted();

    n = clamp(n, Settings.minimum, 1);
    NProgress.status = (n === 1 ? null : n);

    var progress = NProgress.render(!started),
        bar      = progress.querySelector(Settings.barSelector),
        speed    = Settings.speed,
        ease     = Settings.easing;

    progress.offsetWidth; /* Repaint */

    queue(function(next) {
      // Set positionUsing if it hasn't already been set
      if (Settings.positionUsing === '') Settings.positionUsing = NProgress.getPositioningCSS();

      // Add transition
      css(bar, barPositionCSS(n, speed, ease));

      if (n === 1) {
        // Fade out
        css(progress, { 
          transition: 'none', 
          opacity: 1 
        });
        progress.offsetWidth; /* Repaint */

        setTimeout(function() {
          css(progress, { 
            transition: 'all ' + speed + 'ms linear', 
            opacity: 0 
          });
          setTimeout(function() {
            NProgress.remove();
            next();
          }, speed);
        }, speed);
      } else {
        setTimeout(next, speed);
      }
    });

    return this;
  };

  NProgress.isStarted = function() {
    return typeof NProgress.status === 'number';
  };

  /**
   * Shows the progress bar.
   * This is the same as setting the status to 0%, except that it doesn't go backwards.
   *
   *     NProgress.start();
   *
   */
  NProgress.start = function() {
    if (!NProgress.status) NProgress.set(0);

    var work = function() {
      setTimeout(function() {
        if (!NProgress.status) return;
        NProgress.trickle();
        work();
      }, Settings.trickleSpeed);
    };

    if (Settings.trickle) work();

    return this;
  };

  /**
   * Hides the progress bar.
   * This is the *sort of* the same as setting the status to 100%, with the
   * difference being `done()` makes some placebo effect of some realistic motion.
   *
   *     NProgress.done();
   *
   * If `true` is passed, it will show the progress bar even if its hidden.
   *
   *     NProgress.done(true);
   */

  NProgress.done = function(force) {
    if (!force && !NProgress.status) return this;

    return NProgress.inc(0.3 + 0.5 * Math.random()).set(1);
  };

  /**
   * Increments by a random amount.
   */

  NProgress.inc = function(amount) {
    var n = NProgress.status;

    if (!n) {
      return NProgress.start();
    } else {
      if (typeof amount !== 'number') {
        amount = (1 - n) * clamp(Math.random() * n, 0.1, 0.95);
      }

      n = clamp(n + amount, 0, 0.994);
      return NProgress.set(n);
    }
  };

  NProgress.trickle = function() {
    return NProgress.inc(Math.random() * Settings.trickleRate);
  };

  /**
   * Waits for all supplied jQuery promises and
   * increases the progress as the promises resolve.
   *
   * @param $promise jQUery Promise
   */
  (function() {
    var initial = 0, current = 0;

    NProgress.promise = function($promise) {
      if (!$promise || $promise.state() === "resolved") {
        return this;
      }

      if (current === 0) {
        NProgress.start();
      }

      initial++;
      current++;

      $promise.always(function() {
        current--;
        if (current === 0) {
            initial = 0;
            NProgress.done();
        } else {
            NProgress.set((initial - current) / initial);
        }
      });

      return this;
    };

  })();

  /**
   * (Internal) renders the progress bar markup based on the `template`
   * setting.
   */

  NProgress.render = function(fromStart) {
    if (NProgress.isRendered()) return document.getElementById('nprogress');

    addClass(document.documentElement, 'nprogress-busy');
    
    var progress = document.createElement('div');
    progress.id = 'nprogress';
    progress.innerHTML = Settings.template;

    var bar      = progress.querySelector(Settings.barSelector),
        perc     = fromStart ? '-100' : toBarPerc(NProgress.status || 0),
        parent   = document.querySelector(Settings.parent),
        spinner;
    
    css(bar, {
      transition: 'all 0 linear',
      transform: 'translate3d(' + perc + '%,0,0)'
    });

    if (!Settings.showSpinner) {
      spinner = progress.querySelector(Settings.spinnerSelector);
      spinner && removeElement(spinner);
    }

    if (parent != document.body) {
      addClass(parent, 'nprogress-custom-parent');
    }

    parent.appendChild(progress);
    return progress;
  };

  /**
   * Removes the element. Opposite of render().
   */

  NProgress.remove = function() {
    removeClass(document.documentElement, 'nprogress-busy');
    removeClass(document.querySelector(Settings.parent), 'nprogress-custom-parent');
    var progress = document.getElementById('nprogress');
    progress && removeElement(progress);
  };

  /**
   * Checks if the progress bar is rendered.
   */

  NProgress.isRendered = function() {
    return !!document.getElementById('nprogress');
  };

  /**
   * Determine which positioning CSS rule to use.
   */

  NProgress.getPositioningCSS = function() {
    // Sniff on document.body.style
    var bodyStyle = document.body.style;

    // Sniff prefixes
    var vendorPrefix = ('WebkitTransform' in bodyStyle) ? 'Webkit' :
                       ('MozTransform' in bodyStyle) ? 'Moz' :
                       ('msTransform' in bodyStyle) ? 'ms' :
                       ('OTransform' in bodyStyle) ? 'O' : '';

    if (vendorPrefix + 'Perspective' in bodyStyle) {
      // Modern browsers with 3D support, e.g. Webkit, IE10
      return 'translate3d';
    } else if (vendorPrefix + 'Transform' in bodyStyle) {
      // Browsers without 3D support, e.g. IE9
      return 'translate';
    } else {
      // Browsers without translate() support, e.g. IE7-8
      return 'margin';
    }
  };

  /**
   * Helpers
   */

  function clamp(n, min, max) {
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }

  /**
   * (Internal) converts a percentage (`0..1`) to a bar translateX
   * percentage (`-100%..0%`).
   */

  function toBarPerc(n) {
    return (-1 + n) * 100;
  }


  /**
   * (Internal) returns the correct CSS for changing the bar's
   * position given an n percentage, and speed and ease from Settings
   */

  function barPositionCSS(n, speed, ease) {
    var barCSS;

    if (Settings.positionUsing === 'translate3d') {
      barCSS = { transform: 'translate3d('+toBarPerc(n)+'%,0,0)' };
    } else if (Settings.positionUsing === 'translate') {
      barCSS = { transform: 'translate('+toBarPerc(n)+'%,0)' };
    } else {
      barCSS = { 'margin-left': toBarPerc(n)+'%' };
    }

    barCSS.transition = 'all '+speed+'ms '+ease;

    return barCSS;
  }

  /**
   * (Internal) Queues a function to be executed.
   */

  var queue = (function() {
    var pending = [];
    
    function next() {
      var fn = pending.shift();
      if (fn) {
        fn(next);
      }
    }

    return function(fn) {
      pending.push(fn);
      if (pending.length == 1) next();
    };
  })();

  /**
   * (Internal) Applies css properties to an element, similar to the jQuery 
   * css method.
   *
   * While this helper does assist with vendor prefixed property names, it 
   * does not perform any manipulation of values prior to setting styles.
   */

  var css = (function() {
    var cssPrefixes = [ 'Webkit', 'O', 'Moz', 'ms' ],
        cssProps    = {};

    function camelCase(string) {
      return string.replace(/^-ms-/, 'ms-').replace(/-([\da-z])/gi, function(match, letter) {
        return letter.toUpperCase();
      });
    }

    function getVendorProp(name) {
      var style = document.body.style;
      if (name in style) return name;

      var i = cssPrefixes.length,
          capName = name.charAt(0).toUpperCase() + name.slice(1),
          vendorName;
      while (i--) {
        vendorName = cssPrefixes[i] + capName;
        if (vendorName in style) return vendorName;
      }

      return name;
    }

    function getStyleProp(name) {
      name = camelCase(name);
      return cssProps[name] || (cssProps[name] = getVendorProp(name));
    }

    function applyCss(element, prop, value) {
      prop = getStyleProp(prop);
      element.style[prop] = value;
    }

    return function(element, properties) {
      var args = arguments,
          prop, 
          value;

      if (args.length == 2) {
        for (prop in properties) {
          value = properties[prop];
          if (value !== undefined && properties.hasOwnProperty(prop)) applyCss(element, prop, value);
        }
      } else {
        applyCss(element, args[1], args[2]);
      }
    }
  })();

  /**
   * (Internal) Determines if an element or space separated list of class names contains a class name.
   */

  function hasClass(element, name) {
    var list = typeof element == 'string' ? element : classList(element);
    return list.indexOf(' ' + name + ' ') >= 0;
  }

  /**
   * (Internal) Adds a class to an element.
   */

  function addClass(element, name) {
    var oldList = classList(element),
        newList = oldList + name;

    if (hasClass(oldList, name)) return; 

    // Trim the opening space.
    element.className = newList.substring(1);
  }

  /**
   * (Internal) Removes a class from an element.
   */

  function removeClass(element, name) {
    var oldList = classList(element),
        newList;

    if (!hasClass(element, name)) return;

    // Replace the class name.
    newList = oldList.replace(' ' + name + ' ', ' ');

    // Trim the opening and closing spaces.
    element.className = newList.substring(1, newList.length - 1);
  }

  /**
   * (Internal) Gets a space separated list of the class names on the element. 
   * The list is wrapped with a single space on each end to facilitate finding 
   * matches within the list.
   */

  function classList(element) {
    return (' ' + (element.className || '') + ' ').replace(/\s+/gi, ' ');
  }

  /**
   * (Internal) Removes an element from the DOM.
   */

  function removeElement(element) {
    element && element.parentNode && element.parentNode.removeChild(element);
  }

  return NProgress;
});



/***/ })

/******/ });
//# sourceMappingURL=browser_bundle.js.map