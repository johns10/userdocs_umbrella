import {handle_message} from "../commands/commands.js"

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
      
      var element = e.target.closest('button');

      const selector = document.getElementById("selector-transfer-field").value;
      const strategy = document.getElementById("strategy-transfer-field").value;

      const selectorFieldId = element.attributes["selector"].value;
      const strategyFieldId = element.attributes["strategy"].value;

      const targetSelectorField = document.getElementById(selectorFieldId);
      const targetStrategyField = document.getElementById(strategyFieldId);

      targetSelectorField.value = selector;
      targetStrategyField.value = strategy;
    });
  }
};

export {Hooks}