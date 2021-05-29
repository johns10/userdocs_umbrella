import {handle_job, handle_message} from "../commands/commands.js"
import {finder} from '@medv/finder'


var selector = ""

var mouseX = null
var mouseY = null

var XPATH = null
var CSSS = null

const XPATH_STRATEGY_TYPE = 1
const CSS_STRATEGY_TYPE = 2

function main() {
  console.log("Initializing Browser stuff")
  
  window.active_annotations = []

  window.onload = function(event) {
    console.log("Re-establishing runner")
    chrome.storage.local.get(['job', 'configuration'], function (result) {
      if (result == null) {
        console.log("No job found, not resuming runner")
      } else {
        handle_job(result.job, { environment: 'browser'})
      }
    })
  };
  
  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    var logSuffix = sender.tab ? "from a content script:" + sender.tab.url : "from the extension"
    console.log("Browser received message " + logSuffix)
    handle_message(request, { environment: 'browser'})
  });
  
  document.onmousemove = function(event) {
    mouseX = event.clientX;
    mouseY = event.clientY;
  }
  
  document.onkeydown = function(event) {
    const x = event.keyCode;
    if (x === 67) {
      chrome.storage.local.get(['strategy'], function (result) {  
        console.log("Retreived config from storage")
        const elementMouseIsOver = document.elementFromPoint(mouseX, mouseY);
        console.log(elementMouseIsOver)
  
        const configuration = {
          environment: 'browser',
          strategy: result.strategy
        }

        if (result.strategy.name === 'xpath') {
          selector = XPATH
        } else if (result.strategy.name === 'css') {
          selector = finder(elementMouseIsOver);
        }
  
        const message = {
          type: 'step',
          payload: {
            id: 0,
            status: 'not_started',
            process: {
              steps: [
                {
                  id: 0,
                  selector: selector,
                  strategy: result.strategy,
                  step_type: {
                    name: "Set Selector"
                  }
                }
              ]
            }
          }
        }
  
        handle_message(message, configuration)
      });
    }
  }
}

  
function getPathTo(element) {
  if (element === document.body)
      return element.tagName.toLowerCase();

  var ix= 0;
  var siblings= element.parentNode.childNodes;
  for (var i= 0; i<siblings.length; i++) {
      var sibling= siblings[i];
      
      if (sibling===element) return getPathTo(element.parentNode) + '/' + element.tagName.toLowerCase() + '[' + (ix + 1) + ']';
      
      if (sibling.nodeType===1 && sibling.tagName === element.tagName) {
          ix++;
      }
  }
}


export {main}