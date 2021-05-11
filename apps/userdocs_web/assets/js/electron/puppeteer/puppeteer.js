const puppeteer = require('puppeteer');
const { annotations, badge, styleLabel, styleBadge, styleWrapper, outline, 
  createOutlineElement, badgeOutline, blur } = require('../../annotation/annotation.js');
const { getElement, waitForElement, elementSize, ElementNotFound } = require('../../commands/elements.js');
const { currentPage, getElementHandle } = require('./helpers.js');
const Step = require('./step.js');
const app = require('electron').app;
const isDev = require('electron-is-dev');

async function openBrowser(configuration) {
  if (isDev) {
    var executablePath = puppeteer.executablePath()
  } else {
    var executablePath = 
      puppeteer
        .executablePath()
        .replace("app.asar", "app.asar.unpacked")
    console.log(executablePath)
  }
  const args = 
    puppeteer
      .defaultArgs()
      .filter(arg => String(arg).toLowerCase() !== '--disable-extensions')
      .filter(arg => String(arg).toLowerCase() !== '--headless')
      
  if (configuration.user_data_dir_path) {
    args.push('--user-data-dir=' + configuration.user_data_dir_path);
  }

  const browser = await puppeteer.launch({ 
    executablePath: executablePath, 
    ignoreDefaultArgs: true, 
    args: args 
  });

  return browser
}

async function closeBrowser(browser) {
  browser.close()
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

async function testSelector(browser, message) {
  let handle = await getElementHandle(browser, message.selector, message.strategy)
  const page = await currentPage(browser)
  if (handle != undefined) {
    await page.evaluate(handle => { 
      console.log(window.test_annotation)
      if (window.test_annotation) { document.body.removeChild(window.test_annotation) };
      let rect = handle.getBoundingClientRect();
      const overlay = document.createElement('div');
      overlay.style.position = 'fixed';
      overlay.style.width = Math.round(rect.width).toString() + 'px'
      overlay.style.height = Math.round(rect.height).toString() + 'px'
      overlay.style.outline = 'orange solid 1px';
      overlay.style.top = Math.round(rect.top).toString() + 'px';
      overlay.style.left = Math.round(rect.left).toString() + 'px';
      overlay.style.backgroundColor = 'orange';
      overlay.style.opacity = 0.2;
      overlay.style.zIndex = 99999;
      window.test_annotation = overlay;
      document.body.appendChild(overlay);

    }, handle) 
  } else {
    throw new Error("Element not found")
  }
}

function stepInstanceHandler(stepInstance, config) {
  const functions = {
    "Navigate": async () => { return Step.navigate(config.browser, stepInstance) },
    "Click": async () => { return Step.click(config.browser, stepInstance) },
    "Fill Field": async () => { return Step.setValue(config.browser, stepInstance) },
    "Set Size Explicit": async () => { return Step.setSize(config.browser, stepInstance) },
    "Element Screenshot": async () => { return Step.elementScreenshot(config.browser, stepInstance) },
    "Full Screen Screenshot": async () => { return Step.fullScreenScreenshot(config.browser, stepInstance) },
    "Clear Annotations": async () => { return Step.clearAnnotations(config.browser, stepInstance) },
    "Start Process": async () => { return Step.startProcess(config.window, stepInstance) },
    "Complete Process": async () => { return Step.completeProcess(config.window, stepInstance) },
    "Scroll to Element": async () => {  return Step.scrollIntoView(config.browser, stepInstance) },
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
module.exports.testSelector = testSelector
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