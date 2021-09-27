const { GraphQLClient, gql } = require('graphql-request')

let Hooks = {}


Hooks.authenticationEvents = {
  mounted() {
    this.handleEvent("login-succeeded", (message) => {
      const browserStatus = {server: "not_running", client: "not_running", runner: "not_running"}
      if (!window.userdocs) this.pushEventTo('#services-status-hook', "put-services-status", browserStatus)
      else {
        window.userdocs.putTokens(message)
          .then(result => {
            if (result.status == "ok") {
              window.userdocs.startServices()
                .then(result => {
                  this.pushEventTo('#services-status-hook', "put-services-status", result)
                })
            }
          })
      }
    })
  }
}

Hooks.dragDropReorder = {
  mounted() {
    this.el.addEventListener("drop", e => {
      e.preventDefault();
      this.pushEvent("reorder_end", { "step-id": e.target.id  })
    })
    this.el.addEventListener("dragenter", e => {
      e.dataTransfer.dropEffect = 'move'
      e.preventDefault(); 
      if (e.target.id) {
        const element = document.getElementById(e.target.id) 
        var order = element.getAttribute('order');
        var stepId = element.getAttribute('step-id');
        this.pushEvent("reorder_dragenter", {"order": order, "step-id": stepId})
      }
    })
    this.el.addEventListener("dragstart", e => {
      e.dataTransfer.dropEffect = "move";
      const element = document.getElementById(e.target.id) 
      var id = element.getAttribute('step-id');
      this.pushEvent("reorder_start", {"id": id})
    })
    this.el.addEventListener("dragend", e => {
      this.pushEvent("reorder_dragend")
    })
  }
}

Hooks.marginFields = {
  mounted() {
    this.el.addEventListener("input", e => {
      updateValue("margin-top-input", this.el.value)
      updateValue("margin-bottom-input", this.el.value)
      updateValue("margin-left-input", this.el.value)
      updateValue("margin-right-input", this.el.value)
    })
  }
}

function updateValue(selector, value) {
  const element = document.querySelector(`[data-userdocs = ${selector}`)
  element.value = value
}

export {Hooks}