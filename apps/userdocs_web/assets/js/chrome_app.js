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
  handle_message(message, { environment: 'extension' })
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
Hooks.selectorTransfer = {
  mounted() {
    this.el.addEventListener("selector", e => {
      console.log("Got a selector")
      console.log(e.detail)
      this.pushEventTo('#selector-handler', "transfer_selector", e.detail)
    })
  }
};
Hooks.configure = {
  mounted() {
    this.handleEvent("configure", (message) => {
      handle_message(message, { environment: 'extension' })
    })
  }
};
Hooks.testSelector = {
  mounted() {
    this.handleEvent("test_selector", (message) => {
      console.log("Testing Selector");
      console.log(message)
      chrome.storage.local.get(['activeTabId'], function (result) {
        message.payload.activeTabId = result.activeTabId
        handle_message(message, {environment: 'extension'})
      });
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
            handle_message(message, { environment: 'extension' })
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
            handle_message(message, { environment: 'extension' })
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
      console.log(e.srcElement.attributes)

      const selector = document.getElementById("selector-transfer-field").value;
      const strategy = document.getElementById("strategy-transfer-field").value;

      const selectorId = e.srcElement.attributes["selector"].value;
      const strategyId = e.srcElement.attributes["strategy"].value;

      const selectorField = document.getElementById(selectorId);
      const strategyField = document.getElementById(strategyId);

      selectorField.value = selector;
      strategyField.value = strategy;
    });
  }
};

console.log("Before xhr cookie")
console.log((' ' + document.cookie).slice(1))

var xhr = new XMLHttpRequest();
xhr.responseType = 'document';
xhr.open('GET', 'http://app.davenport.rocks:4000/process_administrator', true)
xhr.onload = function(e) {
  document.documentElement.replaceChild(this.response.head, document.head)
  document.documentElement.replaceChild(this.response.body, document.body)

  console.log("After xhrc cookie")
  console.log((' ' + document.cookie).slice(1))

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let newCookie = document.querySelector("[data-phx-main='true']").getAttribute("data-phx-session")

  console.log(newCookie)
  console.log(csrfToken)

  let newCookieString = "_userdocs_web_key=" + newCookie + ";domain=.davenport.rocks;";
  console.log(newCookieString)

  document.cookie = newCookieString

  console.log("After setting cookie")
  console.log(document.cookie)

  let liveSocket = new LiveSocket("ws://app.davenport.rocks:4000/live", Socket, {
    params: { _csrf_token: csrfToken},
    hooks: Hooks
  })
  
  window.addEventListener("phx:page-loading-start", info => NProgress.start())
  window.addEventListener("phx:page-loading-stop", info => NProgress.done())
  
  liveSocket.connect()
  
  window.liveSocket = liveSocket
}
xhr.send()


/*
var xhr = new XMLHttpRequest();
xhr.open('GET', 'http://localhost:4000', true)
xhr.responseType = 'document'
xhr.onload = function(e) {
  console.log(this.response)
  let sess = new XMLHttpRequest();
  sess.open('GET', 'http://localhost:4000/api/v1/session', true)
  sess.onload = function(e) {
    console.log(this.response)

    document.cookie = "_userdocs_web_key" + this.response.cookie
    
    let liveSocket = new LiveSocket("ws://localhost:4000/live", Socket, {
      params: { _csrf_token: this.response.csrfToken},
      hooks: Hooks
    })
  
    window.addEventListener("phx:page-loading-start", info => NProgress.start())
    window.addEventListener("phx:page-loading-stop", info => NProgress.done())
    
    liveSocket.connect()
    
    window.liveSocket = liveSocket
  }
  sess.send()
}
xhr.send()
*/