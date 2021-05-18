import {handle_message} from "../commands/commands.js"

let Hooks = {}

Hooks.testSelector = {
  mounted() {
    this.handleEvent("test_selector", (message) => {
      window.userdocs.testSelector(message)
    })
  }
};
Hooks.automatedBrowserCommands = {
  mounted() {
    this.handleEvent("open-browser", (message) => {
      console.log("open browser")
      window.userdocs.openBrowser()
    })
    this.handleEvent("close-browser", (message) => {
      console.log("close browser")
      window.userdocs.closeBrowser()
    })
  }
};

Hooks.automatedBrowserEvents = {
  mounted() {
    this.el.addEventListener("browser-opened", (message) => {
      console.log("automation browser opened in hook")
      console.log(message)
      this.pushEventTo("#automated-browser-controls", "browser-opened", message.detail)
    })
    this.el.addEventListener("browser-closed", (message) => {
      console.log("automation browser closed in hook")
      console.log(message)
      this.pushEventTo("#automated-browser-controls", "browser-closed", message.detail)
    })
  }
};

Hooks.fileTransfer = {
  mounted() {
    this.el.addEventListener("screenshot", e => {
      console.log("Got a file")
      this.pushEventTo('#screenshot-handler-component', "create_screenshot", e.detail)
    })
  }
};

Hooks.stepStatus = {
  mounted() {
    this.el.addEventListener("update-step", e => {
      //console.log("Got a step update")
      this.pushEventTo('#step-' + e.detail.step_id + '-status', "update_step", e.detail)
    })
  }
};

Hooks.executeProcess = {
  mounted() {
    this.handleEvent("execute-process", (message) => {
      //console.log("Hook triggered for execute process")
      window.userdocs.executeProcess(message)
    })
    this.el.addEventListener("update-process", e => {
      //console.log("executeProcess hook got an update for process " + e.detail.attrs.step.process.id + " to " + e.detail.status)
      this.pushEventTo('#process-' + e.detail.attrs.step.process.id + '-runner', "update_process", e.detail)
    })
  }
};

Hooks.automationManager = {
  mounted() {
    this.handleEvent("put-job", (message) => {
      window.userdocs.putJob(message)
    })
    this.handleEvent("start-running", (message) => {
      window.userdocs.start(message)
    })
    this.handleEvent("execute", (message) => { window.userdocs.execute(message.step) })
    this.el.addEventListener("update-step-instance", (message) => {
      this.pushEventTo("#automation-manager", "update-step-instance", message.detail)
    })
  }
}

Hooks.configuration = {
  mounted() {
    this.handleEvent("configure", (message) => {
      window.userdocs.configure(message)
    })
  }
}

// TODO: THIS IS FOR THE EXTENSION AND SHOULD BE REMOVED 
Hooks.configure = {
  mounted() {
    this.handleEvent("configure", (message) => {
      handle_message(message, { environment: 'extension' })
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
Hooks.test = {
  mounted() {
    this.handleEvent("test", (message) => {
      console.log("test")
    })
  }
}
Hooks.jobRunner = {
  mounted() {
    this.handleEvent("message", (message) => {
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