// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import {handle_message} from "./commands.js"


chrome.runtime.onMessage.addListener(
	function(message, sender, sendResponse) {
    console.log("Extension received message")
		console.log(sender.tab ?
							"from a content script:" + sender.tab.url :
              "from the extension");
            
  console.log("handling message in the listener")
  handle_message(message, 'extension')
});

const updateEvent = new CustomEvent('update', {
  bubbles: false,
  detail: {  }
});

let Hooks = {}
Hooks.fileTransfer = {
  mounted() {
    this.el.addEventListener("message", e => {
      console.log("Got a file")
      this.pushEventTo('#screenshot-handler-component', "create_screenshot", e.detail)
    })
  }
};
Hooks.jobRunner = {
  mounted() {
    this.handleEvent("message", (message) =>
    {
      const type = message.type
      if (type === 'process') {
        const thisProcessId =  this.el.attributes["phx-value-process-id"].value
        const messageProcessId = message.payload.process.id

        if(thisProcessId == messageProcessId) {
          chrome.storage.local.get(['activeTabId', 'activeWindowId'], function (result) {
            message.payload.activeTabId = result.activeTabId
            message.payload.activeWindowId = result.activeWindowId
            handle_message(message, 'extension')
          })
        }
      }
    }),
    this.el.addEventListener("message", e => {
      console.log("Got a job update")
      var payload = {
        status: e.detail.status,
        error: e.detail.error
      }
      this.pushEventTo('#' + e.detail.element_id, "update_status", payload)
    })
  }
};
Hooks.executeStep = {
  mounted() {
    this.handleEvent("message", (message) =>
    {
      const type = message.type
      if (type === 'step') {
        const thisStepId =  this.el.attributes["phx-value-step-id"].value
        const messageStepId = message.payload.process.steps[0].id
        
        if(thisStepId == messageStepId) {
          chrome.storage.local.get(['activeTabId', 'activeWindowId'], function (result) {
            message.payload.activeTabId = result.activeTabId
            message.payload.activeWindowId = result.activeWindowId
            handle_message(message, 'extension')
          })
        }
      }
    }),
    this.el.addEventListener("message", e => {
      console.log("Got a step update")
      console.log(e.detail)
      var payload = {
        status: e.detail.status,
        error: e.detail.error
      }
      this.pushEventTo('#' + e.detail.element_id, "update_job_status", payload)
    })
  }
};
Hooks.CopySelector = {
  mounted: function mounted() {
    this.el.addEventListener("click", function (e) {
      console.log("Copying Selector");
      console.log(e.srcElement.attributes);
      var selector = document.getElementById("selector-transfer-field").value;
      var targetId = e.srcElement.attributes["target"].value;
      var target = document.getElementById(targetId);
      target.value = selector;
    });
  }
};
Hooks.testSelector = {
  mounted: function mounted() {
    this.el.addEventListener("click", function (e) {
      console.log("Testing Selector");
      chrome.storage.local.get(['activeTabId'], function (result) {
        console.log(e.srcElement.attributes);
        var message = {
          type: 'command',
          subType: 'testSelector',
          target: result.activeTabId,
          args: {
            selector: e.srcElement.attributes["selector"].value
          }
        };
        messageHandler.apply(message);
      });
    });
  }
};

var xhr = new XMLHttpRequest();
xhr.responseType = 'document';
xhr.open('GET', 'http://localhost:4000/automation', true)
xhr.onload = function(e) {
  document.documentElement.replaceChild(this.response.head, document.head)
  document.documentElement.replaceChild(this.response.body, document.body)

  var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("ws://localhost:4000/live", Socket, {
    params: { _csrf_token: csrfToken},
    hooks: Hooks
  })
  
  window.addEventListener("phx:page-loading-start", info => NProgress.start())
  window.addEventListener("phx:page-loading-stop", info => NProgress.done())
  
  liveSocket.connect()
  
  window.liveSocket = liveSocket
}
xhr.send()

