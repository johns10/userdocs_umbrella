const { app, ipcMain } = require('electron');
const { handleStepStatusUpdate } = require('./main_window/events.js');
const { 
  stepInstanceHandler, 
  succeed, fail, start, 
  COMPLETE, FAILED, STARTED } = require('../step/step_instance.js');
const { 
  mainWindow, 
  navigateToLoginPage, 
  authenticateJohnDavenport, 
  createMainWindow } = require('./main_window/navigation.js')
const puppeteer = require('./puppeteer/puppeteer.js')
try {
	require('electron-reloader')(module);
} catch {}

userdocs = {
  browser: null,
  browserExecutionQueue: [],
  process: {},
  runState: 'stopped'
}


function main() {
  var mainWindow = createMainWindow();
  mainWindow = navigateToLoginPage(mainWindow);
  mainWindow = authenticateJohnDavenport(mainWindow);
  startQueueProcessorEventLoop()
}

function startQueueProcessorEventLoop() {
  setTimeout(startQueueProcessorEventLoop, 500);
  console.log(userdocs.browserExecutionQueue.length)
  console.log(userdocs.runState)
  if(userdocs.runState === 'running') {
    if (userdocs.browserExecutionQueue === undefined || userdocs.browserExecutionQueue.length == 0) {
      userdocs.runState = 'stopped'
    } else {
      userdocs.runState = 'executing'
      processQueue()
    }
  }
}

async function processQueue() {
  const stepInstance = userdocs.browserExecutionQueue.shift()
  if (stepInstance) {
    console.log("Shifted " + stepInstance.name)
    completeStepInstance = await executeStepInstance(stepInstance)
    if (completeStepInstance.status === COMPLETE) {
      console.log("Step completed, processing next item")
      await new Promise(resolve => setTimeout(resolve, 200));
      await processQueue()
    } else if (completeStepInstance.status === FAILED) {
      console.log("Step Failed, stop and unshift item")
      userdocs.runState = 'stopped'
      userdocs.browserExecutionQueue.unshift(completeStepInstance)
    } else {
      console.log("Uncaught condition, stop")
      userdocs.runState = 'stopped'
    }
  } else {
    console.log("Probably null stepinstance, stop")
    userdocs.runState = 'stopped'
  }
}

ipcMain.on('openBrowser', async (event) => { 
  userdocs.browser = await openBrowser()
  return true
})

async function openBrowser() {
  automationModule = puppeteer

  var browser = await automationModule.openBrowser()
  browser = await automationModule.preload(browser) 
  browser = await automationModule.configureDisconnectEvent(browser, mainWindow())
  mainWindow().webContents.send('browserOpened', { sessionId: automationModule.id(browser) })  
  return browser
}

ipcMain.on('closeBrowser', async (event) => { 
  automationModule = puppeteer
  browser = userdocs.browser

  await automationModule.closeBrowser(browser)
  mainWindow().webContents.send('browserClosed', automationModule.id(browser))
  userdocs.browser = null
  return true
})

ipcMain.on('execute', async (event, stepInstance) => {
  executeStepInstance(stepInstance)
})

async function executeStepInstance (stepInstance) {
  automationModule = puppeteer
  if(userdocs.browser === null) { userdocs.browser = await openBrowser() }
  browser = userdocs.browser

  config = { browser: browser, window: mainWindow() }

  stepInstance = start(stepInstance)
  handleStepStatusUpdate(stepInstance, config)
  
  try {
    const stepFunction = automationModule.stepInstanceHandler(stepInstance, config)
    await stepFunction()
    stepInstance = succeed(stepInstance)
    handleStepStatusUpdate(stepInstance, config)
    return stepInstance
  } catch(error) { 
    stepInstance = fail(stepInstance, error)
    console.log(stepInstance.name + " Failed to execute because " + error)
    handleStepStatusUpdate(stepInstance, config)
    return stepInstance
  }
}

ipcMain.on('putJob', (event, job) => {
  userdocs.browserExecutionQueue = job.data
})

ipcMain.on('start', (event) => {
  userdocs.runState = 'running'
})

ipcMain.on('executeProcess', async (event, job) => {
  if(userdocs.browser === null) { userdocs.browser = await openBrowser() }
  userdocs.browserExecutionQueue = job.data
  userdocs.runState = 'running'
})

app.whenReady().then(main)