const { succeed, fail, start } = require('../../step/step_instance.js');
  const { currentPage, getElementHandle } = require('./helpers.js')
const Puppeteer = require('./puppeteer.js')
const { writeFile  } = require('fs/promises')

async function navigate(browser, stepInstance) { 
  url = stepInstance.attrs.page.url

  const page = await currentPage(browser)
  await page.goto(url) 
  return stepInstance
}

async function click(browser, stepInstance) {
  selector = stepInstance.attrs.element.selector
  strategy = stepInstance.attrs.element.strategy.name

  let handle = await getElementHandle(browser, selector, strategy)
  await handle.click()
  return stepInstance
}

async function setValue(browser, stepInstance) {
  selector = stepInstance.attrs.element.selector
  strategy = stepInstance.attrs.element.strategy.name
  text = stepInstance.attrs.text

  let handle = await getElementHandle(browser, selector, strategy)
  await handle.type(text);
  return stepInstance
}

async function setSize(browser, stepInstance) {
  width = stepInstance.attrs.width
  height = stepInstance.attrs.height

  page = await currentPage(browser)
  await page.setViewport({
    width: width,
    height: height,
    deviceScaleFactor: 1,
  })
  return stepInstance
}

async function elementScreenshot(browser, stepInstance) {
  selector = stepInstance.attrs.element.selector
  strategy = stepInstance.attrs.element.strategy.name
  file_name = stepInstance.attrs.process.name + " " + stepInstance.attrs.order

  let handle = await getElementHandle(browser, selector, strategy)
  let base_64 = await handle.screenshot({ encoding: "base64"});
  if (stepInstance.attrs.screenshot === null) { 
    stepInstance.attrs.screenshot = { base_64: base_64}
  } else {
    stepInstance.attrs.screenshot.base_64 = base_64
  }
  handle.screenshot({path: userdocs.configuration.image_path + "\\" + file_name + ".png"});
  return stepInstance
}

async function fullScreenScreenshot(browser, stepInstance) {
  file_name = stepInstance.attrs.process.name + " " + stepInstance.attrs.order
  const page = await currentPage(browser)

  buffer = await page.screenshot();
  await writeFile(userdocs.configuration.image_path + "\\" + file_name + ".png", buffer)
  return stepInstance
}

async function clearAnnotations(browser, stepInstance) {
  const page = await currentPage(browser)
  page.evaluate(() => {
    for (let i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }
    window.active_annotations = []
  })
  return stepInstance
}

async function applyAnnotation(browser, stepInstance, applyAnnotationFunction) {
  console.log("apply Annotation " + stepInstance.attrs.annotation.annotation_type.name)
  let page = await currentPage(browser) 
  const preloadStatus  = await Puppeteer.hasPreloads(browser)
  if ( !preloadStatus ) { browser = await Puppeteer.preload(browser) }
  try {
    const result = await page.evaluate(applyAnnotationFunction, stepInstance)
    if (result == true) {
      return stepInstance
    } else {
      throw result
    }
  } catch (error) {
    throw error
  }
}

async function scrollIntoView(browser, stepInstance) { 
  selector = stepInstance.attrs.element.selector
  strategy = stepInstance.attrs.element.strategy.name

  const page = await currentPage(browser)
  let handle = await getElementHandle(browser, selector, strategy)
  console.log(handle)
  if (handle != undefined) {
    await page.evaluate(handle => { handle.scrollIntoView() }, handle) 
    return stepInstance
  } else {
    throw new Error("Element not found")
  }
}

async function startProcess(window, stepInstance) { 
  console.log("Updating Process status")
  window.webContents.send('processStatusUpdated', start(stepInstance))
  return stepInstance
}

async function completeProcess(window, stepInstance) { 
  window.webContents.send('processStatusUpdated', succeed(stepInstance))
  return stepInstance
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