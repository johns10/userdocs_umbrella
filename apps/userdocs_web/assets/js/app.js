// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

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


let Hooks = {}
Hooks.editorSource = {
  mounted() {
    this.el.addEventListener("dragstart", e => {
      console.log("Moving")
      e.dataTransfer.dropEffect = "move";
      const payload = {
        "id": e.srcElement.attributes.id.value,
        "type": e.srcElement.attributes.type.value
      }
      this.pushEvent("editor_drag_start", payload)
    })
  }
}
Hooks.docubit = {
  mounted() {
    this.el.addEventListener("drop", e => {
      console.log("Dropping")
      e.preventDefault();
      e.stopPropagation();
      const componentId = e.currentTarget.id
      const draggingElement = document.getElementById("dragging")
      const payload = { 
        "object-id": draggingElement.getAttribute("object-id"),
        "type": draggingElement.getAttribute("object-type") ,
        "docubit-id": e.currentTarget.getAttribute("phx-value-docubit-id")
      }
      console.log(payload)
      this.pushEventTo('#' + componentId, "docubit_drop", payload)
    })
    this.el.addEventListener("dragenter", e => {
      e.dataTransfer.dropEffect = 'move'
      e.preventDefault();
    })
    this.el.addEventListener("dragover", e => {
      e.dataTransfer.dropEffect = 'move'
      e.preventDefault();
    })
  }
}
Hooks.executeStep = {
  mounted() {
    this.el.addEventListener("click", e => {
      console.log("Extension Executing Step");
      console.log(event.target.nodeName)
      // TODO: Find a better way to find the right a.  I could easily 
      // add class navbar-item or something
      var element = event.target.closest('a');
      var activeTabId = null;
      chrome.storage.local.get(['activeTabId'], function (result) {
        activeTabId = result.activeTabId;
        var payload = {
          type: 'command',
          subType: element.attributes["command"].value.toLowerCase(),
          target: activeTabId,
          updateTarget: element.attributes["update-target"].value,
          id: element.id,
          args: {
            url: element.attributes["url"].value,
            strategy: element.attributes["strategy"].value,
            selector: element.attributes["selector"].value
          }
        };
        messageHandler.apply(payload);
      })
    }),
    this.el.addEventListener("update", e => {
      var payload = {
        status: e.detail.status,
        error: e.detail.error
      }
      this.pushEventTo(e.detail.updateTarget, "update_job_status", payload)
    })
  }
};
Hooks.jobRunner = {
  mounted() {
    this.el.addEventListener("run_job", e => {
      console.log("Got a Run Job event")
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

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
