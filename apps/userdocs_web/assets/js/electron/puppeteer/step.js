const { succeed, fail, start } = require('../../step/step_instance.js');
  const { currentPage, getElementHandle } = require('./helpers.js')
const Puppeteer = require('./puppeteer.js')

async function navigate(browser, url) { 
  const page = await currentPage(browser)
  await page.goto(url) 
  return browser
}

async function click(browser, selector, strategy) {
  let handle = await getElementHandle(browser, selector, strategy)
  await handle.click()
  return browser
}

async function setValue(browser, selector, strategy, text) {
  let handle = await getElementHandle(browser, selector, strategy)
  await handle.type(text);
  return browser
}

async function setSize(browser, width, height) {
  page = await currentPage(browser)
  await page.setViewport({
    width: width,
    height: height,
    deviceScaleFactor: 1,
  })
  return browser
}

async function elementScreenshot(browser, selector, strategy) {
  let handle = await getElementHandle(browser, selector, strategy)
  buffer = await handle.screenshot();
  return browser
}

async function fullScreenScreenshot(browser) {
  const page = await currentPage(browser)
  buffer = await page.screenshot();
  return browser
}

async function clearAnnotations(browser, selector, strategy) {
  const page = await currentPage(browser)
  page.evaluate(() => {
    for (let i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }
    window.active_annotations = []
  })
  return browser
}

async function applyAnnotation(browser, stepInstance, applyAnnotationFunction) {
  console.log("apply Annotation " + stepInstance.attrs.annotation.annotation_type.name)
  let page = await currentPage(browser) 
  const preloadStatus  = await Puppeteer.hasPreloads(browser)
  if ( !preloadStatus ) { browser = await Puppeteer.preload(browser) }
  try {
    const result = await page.evaluate(applyAnnotationFunction, stepInstance)
    if (result == true) {
      return browser
    } else {
      throw result
    }
  } catch (error) {
    throw error
  }
}

async function scrollIntoView(browser, selector, strategy) { 
  const page = await currentPage(browser)
  let handle = await getElementHandle(browser, selector, strategy)
  console.log(handle)
  if (handle != undefined) {
    await page.evaluate(handle => { handle.scrollIntoView() }, handle) 
    return browser
  } else {
    throw new Error("Element not found")
  }
}

async function startProcess(window, stepInstance) { 
  console.log("Updating Process status")
  window.webContents.send('processStatusUpdated', start(stepInstance))
  return browser
}

async function completeProcess(window, stepInstance) { 
  window.webContents.send('processStatusUpdated', succeed(stepInstance))
  return browser
}

module.exports.navigate = navigate
module.exports.click = click
module.exports.setValue = setValue
module.exports.setSize = setSize
module.exports.elementScreenshot = elementScreenshot
module.exports.fullScreenScreenshot = fullScreenScreenshot
module.exports.clearAnnotations = clearAnnotations
module.exports.applyAnnotation = applyAnnotation
module.exports.startProcess = startProcess
module.exports.completeProcess = completeProcess
module.exports.scrollIntoView = scrollIntoView