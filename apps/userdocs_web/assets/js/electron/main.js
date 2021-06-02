const { app, ipcMain } = require('electron');
const { 
  mainWindow, 
  navigateToLoginPage, 
  authenticateJohnDavenport, 
  createMainWindow } = require('./main_window/navigation.js')
const path = require('path')
const isDev = require('electron-is-dev');
var Runner
if (isDev) {
  Runner = require('../runner/runner')
} else {
  Runner = require('@userdocs/runner')
}

if (isDev) {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, 'node_modules', '.bin', 'electron')
  });
}

stepUpdated = function(step) { 
  mainWindow().send('stepStatusUpdated', step); 
  return step 
}

processUpdated = function(process) { 
  mainWindow().send('processUpdated', process); 
  return process 
}

userdocs = {
  browser: null,
  browserExecutionQueue: [],
  process: {},
  runState: 'stopped',
  runner: null,
  configuration: {
    automationFrameworkName: 'puppeteer',
    maxRetries: 3,
    environment: 'desktop',
    imagePath: null,
    userDataDirPath: 'default',
    callbacks: {
      step: {
        preExecutionCallbacks: [ 'startLastStepInstance', stepUpdated ],
        executionCallback: 'run',
        successCallbacks: [ 'completeLastStepInstance', stepUpdated ],
        failureCallbacks: [ 'failLastStepInstance', stepUpdated ]
      },
      process: {
        preExecutionCallbacks: [ 'startLastProcessInstance', processUpdated ],
        executionCallback: 'run',
        successCallbacks: [ 'completeLastProcessInstance', processUpdated ],
        failureCallbacks: [ 'failProcessInstance', processUpdated ]
      },
      job: {
        preExecutionCallbacks: [ 'startLastJobInstance' ],
        executionCallback: 'run',
        successCallbacks: [ 'completeLastJobInstance' ],
        failureCallbacks: [ 'failLastJobInstance' ]
      }
    }
  }
}

function main() {
  if(isDev) {
    userdocs.configuration.environment = 'development'
    createMainWindow()
      .then( mainWindow => navigateToLoginPage(mainWindow) )
      .then( mainWindow => authenticateJohnDavenport(mainWindow))
      .catch( e => console.log(e))
  } else {
    createMainWindow()
      .then( mainWindow => navigateToLoginPage(mainWindow) )
      .catch( e => console.log(e))
  }
  userdocs.runner = Runner.initialize(userdocs.configuration)
}

ipcMain.on('openBrowser', async (event) => { 
  if(!userdocs.runner.automationFramework.browser) userdocs.runner = await openBrowser()
  return true
 })

async function openBrowser() {
  if(!userdocs.runner) throw ("No RUnner")
  userdocs.runner = await Runner.openBrowser(userdocs.runner, userdocs.configuration)
  userdocs.runner.automationFramework.browser.on('disconnected', () => browserClosed())
  mainWindow().webContents.send('browserOpened', { sessionId: 'id' })
  return userdocs.runner
}

ipcMain.on('closeBrowser', async (event) => { 
  if(!userdocs.runner) throw ("No RUnner")
  userdocs.runner = await Runner.closeBrowser(userdocs.runner, userdocs.configuration)
  browserClosed('id')
  return true
})

function browserClosed(id) { 
  const browserId = id ? id : null
  mainWindow().webContents.send('browserClosed', browserId)
}

ipcMain.on('execute', async (event, step) => {
  if(!userdocs.runner) throw ("No RUnner")
  if(!userdocs.runner.automationFramework.browser) userdocs.runner = await openBrowser()
  await Runner.executeStep(step, userdocs.runner)
})

ipcMain.on('executeProcess', async (event, process) => {
  if(!userdocs.runner.automationFramework.browser) await openBrowser()
  console.log(`bout to run runner process ${userdocs.runner}`)
  await Runner.executeProcess(process, userdocs.runner)
})

ipcMain.on('executeJob', async (event, job) => {
  if(!userdocs.runner.automationFramework.browser) userdocs.runner = await openBrowser()
  console.log(`bout to run runner job`)
  await Runner.executeJob(job, userdocs.runner)
})

ipcMain.on('start', (event) => {
  userdocs.runState = 'running'
})


ipcMain.on('configure', async (event, message) => {
  if (message.image_path) userdocs.configuration.imagePath = message.image_path
  if (message.user_data_dir_path) userdocs.configuration.userDataDirPath = message.user_data_dir_path
  if (message.strategy) userdocs.configuration.strategy = message.strategy
  try {
    userdocs.runner = Runner.reconfigure(userdocs.runner, userdocs.configuration)
  } catch(e) {
    userdocs.runner = Runner.initialize(userdocs.configuration)
  } 
})

ipcMain.on('testSelector', async (event, message) => {
  automationModule = puppeteer
  automationModule.testSelector(userdocs.browser, message)
})

app.whenReady().then(main)
