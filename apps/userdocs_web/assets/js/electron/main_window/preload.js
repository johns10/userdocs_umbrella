const { ipcRenderer, contextBridge } = require('electron')
const { browserOpened, browserClosed, stepStatusUpdated, processStatusUpdated } = require('./events.js')


console.log('preload')

contextBridge.exposeInMainWorld('userdocs', {
  test: () => { console.log('test')},
  //openBrowser: () => { ipcRenderer.send('openBrowser') },
  openBrowser: () => { ipcRenderer.send('openBrowser') },
  closeBrowser: () => { ipcRenderer.send('closeBrowser') },
  execute: (step_instance) => { ipcRenderer.send('execute', step_instance) },
  executeProcess: (process) => { ipcRenderer.send('executeProcess', process) },
  putJob: (job) => { ipcRenderer.send('putJob', job)},
  start: () => { ipcRenderer.send('start')}
})

ipcRenderer.on('browserOpened', (event, payload) => browserOpened(payload))
ipcRenderer.on('browserClosed', (event, payload) => browserClosed(payload))
ipcRenderer.on('stepStatusUpdated', (event, payload) => stepStatusUpdated(payload))
ipcRenderer.on('processStatusUpdated', (event, payload) => processStatusUpdated(payload))