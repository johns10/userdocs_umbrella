
class ExtensionMessageHandler {
  constructor(chrome, handler) {
    this.chrome = chrome
    this.setHandler(handler)
    this.router = {
      command: {
        click: {
          action: 'send'
        },
        navigate: {
          action: 'execute'
        },
        setSelector: {
          action: 'execute'
        },
        testSelector: {
          action: 'send'
        }
      }
    }
  }

  setHandler(handler) {
    this.handler = handler
  }
  
  route(type, subType) {
    return this.router[type][subType]['action']
  }

  apply(message) {
    var action = this.route(
      message.type, 
      message.subType, 
      this.participant
    )
    console.log("Extension Applying " + action + " action")
    if(action === 'send') {
      console.log("sending a message")
      this.chrome.tabs.sendMessage(
        message.target, 
        message, 
        this.update
      )
    } else if(action === 'execute') {
      var command = new Command(message, this)
      command.apply()
    }
  }

  update(message) {
    console.log("Running the update command in the Extension message handler")
    window.currentJob.update(message)
  }
}

class BrowserMessageHandler {
  constructor(handler = function() {}) {
    this.setHandler(handler)
    this.router = {
      command: {
        click: {
          action: 'execute'
        },
        navigate: {
          action: 'ignore'
        },
        setSelector: {
          action: 'send'
        },
        testSelector: {
          action: 'execute'
        }
      }
    }
  }

  setHandler(handler) {
    this.handler = handler
  }
  
  route(type, subType) {
    return this.router[type][subType]['action']
  }

  apply(message) {
    var action = this.route(message.type, message.subType, this.participant)
    if(action === 'send') {
      this.chrome.runtime.sendMessage(message, this.browserResponseHandler)
    } else if(action === 'execute') {
      var command = new Command(message, this.handler)
      command.apply()
    }
  }
}

class Job {
  constructor(job = {}, stepHandler = new MessageHandler) {
    this.currentStep = null
    this.setJob(job)
    this.setStepHandler(stepHandler)
    this.stepHandler.setHandler(this)
  }

  setStepHandler(stepHandler) {
    this.stepHandler = stepHandler
  }

  setJob(job) {
    this.job = job
  }

  update(message) {
    console.log("Job handler Update Function")
    console.log(message)
    console.log(this.currentStep)
  }

  apply() {
    if (this.job.steps.length == 0) {
      console.log("Finished")
    } else {
      this.currentStep = this.job.steps.shift()
      this.currentStep.target = this.job.target
      console.log(this.currentStep)
      this.stepHandler.apply(this.currentStep)
    }
  }
}
class Command {
  // class methods
  constructor(message = {command: null, args: {}}, callback = null) {
    this.status = "not_started"
    this.prechecks = []
    this.parse(message)
    this.setCallback(callback)
  }

  setCallback(callback) {
    this.callback = callback
  }

  parse(message) {
    console.log("Parsing Message")
    if(message.type === 'command') {
      console.log("Parsing Command")
      if(message.subType === 'click') {
        this.prechecks.push(this.waitForElement)
        this.type = 'click'
        this.handler = this.click
        this.args = {
          strategy: message.args.strategy,
          selector: message.args.selector
        }
      } else if (message.subType === 'navigate') {
        console.log("Parsing navigate command")
        this.type = 'navigate'
        this.handler = this.navigate
        this.target = message.target
        this.args = {
          url: message.args.url
        }
      } else if (message.subType === 'setSelector') {
        console.log("Parsing set selector command")
        this.type = 'setSelector'
        this.handler = this.setSelector
        this.args = {
          selector: message.args.selector
        }
      } else if (message.subType === 'testSelector') {
        console.log("Parsing test selector command")
        this.type = message.subType
        this.handler = this.testSelector
        this.args = {
          selector: message.args.selector
        }
      }else {
        return( { status: "nok", error: "Command type not supported" } )
      }
    } else {
      return( { status: "nok", error: "Message doesn't contain a command" } )
    }
  }

  apply() {
    console.log("Running Apply")
    if(this.status === "not_started" || this.status === "running_prechecks") {
      this.status = "running_prechecks"
      this.run_prechecks(this)
    } else if(this.status == "prechecks_complete") {
      console.log("Applying command")
      this.handler(this)
      console.log("Command " + this.status)
    } else if(this.status == "precheck_failed") {
      console.log(this.status)
      this.callback(this)
    } else if (this.status == "command_failed") {
      console.log(this.status)
      this.callback(this)
    } else if(this.status == "command_complete") {
      console.log(this.status)
      this.callback(this)
    }
  }

  run_prechecks(command) {
    console.log(this.prechecks.length + " prechecks remain")
    if(command.prechecks.length > 0) {
      const precheck = command.prechecks.shift()
      precheck(command)
    } else if(command.prechecks.length === 0) {
      command.status = "prechecks_complete"
      command.apply()
    }
  }

  validateTarget(command) {
    if(command.target) {
      command.status = "running_prechecks"
      command.apply()
    } else {
      command.status = "precheck_failed"
      command.error = "Target not found"
      command.apply()
    }
  }

  waitForElement(command) {
    var timeout = setTimeout(function(){ 
      clearInterval(interval)
      command.status = "precheck_failed"
      command.error = "Element not found"
      console.log("Not found")
      command.apply()
     }, 3000);
    var interval = setInterval(function(){
      var element = document.evaluate(
        command.args.selector, 
        document, 
        null, 
        XPathResult.FIRST_ORDERED_NODE_TYPE, 
        null).singleNodeValue
      if(element) {
        command.status = "running_prechecks"
        clearTimeout(timeout)
        clearInterval(interval)
        console.log("found")
        command.apply()
      }
    }, 100);
  }


  testSelector() {
    try {
      var elements = document.evaluate(
        this.args.selector, 
        document, 
        null, 
        XPathResult.FIRST_ORDERED_NODE_TYPE, 
        null)
      elements.forEach(element => element.style.backgroundColor = "#FDFF47")
      return { status: "ok", error: "" }
    } catch(error) {
      return( { status: "nok", error: error.message } )
    }
  }

  setSelector() {
    var value = this.args.selector
    try {
      console.log("setting selector")
      document.getElementById("selector-transfer-field").value = value;
      return { status: "ok", error: ""}
    } catch(error) {
      return { status: "nok", error: error.message}
    }
  }

  navigate(command) {
    const target = command.target
    const args = command.args

    console.log("Executing navigate")
    console.log(target)
    console.log(args)
    chrome.tabs.update( target, args);
    command.status = "command_complete"
    command.apply()
  }

  click(command) {
    var args = command.args

    if (args.strategy === 'xpath') {
      try {
        var element = document.evaluate(
          args.selector, 
          document, 
          null, 
          XPathResult.FIRST_ORDERED_NODE_TYPE, 
          null).singleNodeValue
        element.click()
        command.status = "command_complete"
        console.log("Calling apply")
        command.apply()
      } catch (error) {
        command.status = "command_failed"
        console.log("Calling apply")
        command.apply()
      }
    }
  }
}

export {handle_job, ExtensionMessageHandler, Command, BrowserMessageHandler, Job}