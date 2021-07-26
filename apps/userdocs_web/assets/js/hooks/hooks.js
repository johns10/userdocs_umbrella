const { GraphQLClient, gql } = require('graphql-request')
var PORT
var CLIENT
const configurationQuery = gql`
  query Query {
    configuration {
      maxRetries
      imagePath
      userDataDirPath
    }
  }
`
function configurationMutation(config) {
  return gql`
    mutation Mutation {
      configuration(maxRetries: ${config.maxRetries}, imagePath: "${config.imagePath}", userDataDirPath: "${config.userDataDirPath}") {
        maxRetries
        imagePath
        userDataDirPath
      }
    }
  `
}

try {
  window.userdocs.port()
    .then(port => {
      PORT = port
      console.log(PORT)
      CLIENT = new GraphQLClient(`http://localhost:${port}`)
    })
} catch(e) {
  console.log("No port, web only")
}

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

Hooks.browserEventHandler = {
  mounted() {
    this.el.addEventListener("browser-event", (message) => {
      console.log("browser event received by hook")
      console.log(message)
      this.pushEventTo("#browser-event-handler", "browser-event", message.detail)
    })
  }
}

Hooks.fileTransfer = {
  mounted() {
    this.el.addEventListener("screenshot", e => {
      console.log("Got a file")
      this.pushEventTo('#screenshot-handler-component', "create_screenshot", e.detail)
    })
  }
};

Hooks.automationManager = {
  mounted() {
    this.handleEvent("start-running", (message) => { window.userdocs.start(message) })
    this.handleEvent("execute", (message) => { window.userdocs.execute(message.step) })
    this.handleEvent("executeProcess", (message) => { window.userdocs.executeProcess(message.process) })
    this.handleEvent("executeJob", (message) => { window.userdocs.executeJob(message.job) })
    this.el.addEventListener("update-step", (message) => {
      this.pushEventTo("#automation-manager", "update-step", { step: message.detail })
    })
    this.el.addEventListener("update-process", (message) => {
      this.pushEventTo('#automation-manager', "update-process", { process: message.detail })
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

Hooks.configurationV2 = {
  mounted() {
    this.handleEvent("get-configuration", (message) => {
      const result = 
        CLIENT.request(configurationQuery)
          .then(result => {
            this.pushEventTo('#configuration-v2-hook', "configuration-response", result)
          })
    }),
    this.handleEvent("put-configuration", (message) => {
      const mutation = configurationMutation(message)
      const result = 
        CLIENT.request(mutation)
        .then(result => {
          this.pushEventTo('#configuration-v2-hook', "configuration-saved", result)
        })
    })
  }
}














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