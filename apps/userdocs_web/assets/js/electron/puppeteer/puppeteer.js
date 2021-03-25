const puppeteer = require('puppeteer');
const { annotations, badge, styleLabel, styleBadge, styleWrapper, outline, 
  createOutlineElement, badgeOutline, blur } = require('../../annotation/annotation.js')
const { getElement, waitForElement, elementSize, ElementNotFound } = require('../../commands/elements.js')
const { currentPage } = require('./helpers.js')
const Step = require('./step.js')

async function openBrowser() {
  const browser = await puppeteer.launch({ headless: false });
  return browser
}

async function closeBrowser(browser) {
  await browser.close()
}

async function preload(browser) {
  const functionsToPreload = [ 
    annotations, badge, styleLabel, styleBadge, styleWrapper, outline, 
    createOutlineElement, getElement, waitForElement, elementSize,
    ElementNotFound, badgeOutline, blur
  ]

  let page = await currentPage(browser) 

  page.evaluate(() => { window.userdocs = {} })
  page.evaluate(() => { window.active_annotations = [] })

  for (const func of functionsToPreload) {
    page.evaluate((name, script) => {
      eval("window.userdocs." + name + " = " + script)
    }, func.name, func.toString())
  }

  return browser
}

async function hasPreloads(browser) {
  let page = await currentPage(browser) 
  const userdocs = await page.evaluate(() => {
    return window.userdocs
  })
  if ( userdocs ) { 
    return true 
  } else { 
    return false
  }
}

async function configureDisconnectEvent(browser, window) {
  browser.on('disconnected', () => {
    window.webContents.send('browserClosed', id(browser))
  });
  return browser
} 

async function waitForNavigationToComplete(browser) {
  page = await currentPage(browser)
  await page.waitForNavigation({waitUntil: 'networkidle0'})
  return true
}

function id(browser) {
  return browser.process().pid.toString()
}

function stepInstanceHandler(stepInstance, config) {
  const functions = {
    "Navigate": async () => { return Step.navigate(config.browser, stepInstance.attrs.page.url) },
    "Click": async () => { return Step.click(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.element.strategy.name) },
    "Fill Field": async () => { return Step.setValue(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.element.strategy.name, stepInstance.attrs.text) },
    "Set Size Explicit": async () => { return Step.setSize(config.browser, stepInstance.attrs.width, stepInstance.attrs.height) },
    "Element Screenshot": async () => { return Step.elementScreenshot(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.element.strategy.name) },
    "Full Screen Screenshot": async () => { return Step.fullScreenScreenshot(config.browser) },
    "Clear Annotations": async () => { return Step.clearAnnotations(config.browser) },
    "Start Process": async () => { return Step.startProcess(config.window, stepInstance) },
    "Complete Process": async () => { return Step.completeProcess(config.window, stepInstance) },
    "Scroll to Element": async () => {  return Step.scrollIntoView(config.browser, stepInstance.attrs.element.selector, stepInstance.attrs.element.strategy.name) },
    "Apply Annotation": async () => { 
      const applyAnnotationFunction = async function(stepInstance, done) {
        try {
          await window.userdocs.waitForElement(stepInstance);
          const apply = window.userdocs.annotations(stepInstance.attrs.annotation.annotation_type.name)
          apply(stepInstance)
          return true
        } catch(error) {
          return error
        }
      }
      return Step.applyAnnotation(config.browser, stepInstance, applyAnnotationFunction) 
    },
    "Send Keys": async () => { 
      return browserAutomation.sendKeys(config.browser, text) 
    },
    "Send Enter Key": async () => { 
      return browserAutomation.sendEnterKey(config.browser) 
    },
    //"Mouse Down, Mouse Up": async () => { return browserAutomation.mouseDownMouseUp(config.browser, stepInstance.attrs.element.selector) },
  }
  const funk = functions[stepInstance.attrs.step_type.name]
  if ( funk ) {
    return funk
  } else {
    throw new Error(stepInstance.attrs.step_type.name + " Not implemented by stepInstanceHandler")
  }
}

module.exports.waitForNavigationToComplete = waitForNavigationToComplete
module.exports.configureDisconnectEvent = configureDisconnectEvent
module.exports.stepInstanceHandler = stepInstanceHandler
module.exports.closeBrowser = closeBrowser
module.exports.openBrowser = openBrowser
module.exports.hasPreloads = hasPreloads
module.exports.preload = preload
module.exports.id = id
/*
module.exports.navigate = navigate
module.exports.setSize = setSize
module.exports.click = click
module.exports.setValue = setValue
module.exports.sendKeys = sendKeys
module.exports.sendEnterKey = sendEnterKey
module.exports.mouseDownMouseUp = mouseDownMouseUp
module.exports.clearAnnotations = clearAnnotations
module.exports.scrollIntoView = scrollIntoView
module.exports.fullScreenScreenshot = fullScreenScreenshot
module.exports.elementScreenshot = elementScreenshot
*/