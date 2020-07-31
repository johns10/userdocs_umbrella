import {handle_message} from '/commands.js';

var PATH = null

export function main () {

  console.log("Initializing Browser stuff")
  window.active_annotations = []
  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    var logSuffix = sender.tab ? "from a content script:" + sender.tab.url : "from the extension"
    console.log("Browser received message " + logSuffix)
    console.log(request)
    handle_message(request, 'browser')
  });
  
  document.onmouseover = function(event) {
    PATH = getPathTo(event.srcElement);
  }
  
  document.onkeydown = function(event) {
    var x = event.keyCode;
    if (x === 67) {
      var message = {
        type: 'command',
        subType: 'setSelector',
        args: {
          selector: PATH
        }
      }
      // var result = messageHandler.apply(message)
      console.log(result)
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
  
  function getPageXY(element) {
    var x= 0, y= 0;
    while (element) {
        x+= element.offsetLeft;
        y+= element.offsetTop;
        element= element.offsetParent;
    }
    return [x, y];
  }
}
