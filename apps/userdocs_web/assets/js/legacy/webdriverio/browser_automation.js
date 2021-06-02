
/*
const { remote } = require('webdriverio');
const { annotations, badge, styleLabel, styleBadge, styleWrapper, outline, createOutlineElement, badgeOutline } = require('../annotation/annotation.js')
const { getElement, waitForElement, elementSize, ElementNotFound } = require('../commands/elements.js')

async function openBrowser() {
  return remote({
    automationProtocol: 'devtools',
    capabilities: {
      browserName: 'chrome',
      'goog:chromeOptions': {},
      'wdio:devtoolsOptions': {}
    }
  })
}

async function closeBrowser(browser) {
  console.log("Closing Browser")
  await browser.deleteSession()
}

async function navigate(browser, url) {
  console.log("navigate")
  return browser.navigateTo(url)
}

async function setSize(browser, width, height) {
  console.log("setSize")
  return browser.setWindowSize(width, height)
}

async function applyAnnotation(browser, stepInstance, applyAnnotationFunction) {
  console.log("apply Annotation " + stepInstance.attrs.annotation.annotation_type.name)
  const preloadStatus  = await hasPreloads(browser)
  if ( !preloadStatus ) { browser = await preload(browser) }
  try {
    const result = await browser.executeAsync(applyAnnotationFunction, stepInstance)
    if (result == true) {
      return browser
    } else {
      throw result
    }
  } catch (error) {
    throw error
  }
}

async function click(browser, selector) {
  return (await browser.$(selector)).click()
}

async function mouseDownMouseUp(browser, selector) {
  const element = await browser.$(selector)
  await browser.performActions([
    {
      "type": 'pointer',
      "id": 'mouse1',
      "parameters": { "pointerType": 'mouse' },
      "actions": [
        {
          "type": 'pointerDown',
          "origin": 'pointer',
          "x": element.getLocation('x') - 1,
          "y": element.getLocation('y') - 1
        }
      ]
    },
    {
      "type": 'pointer',
      "id": 'mouse1',
      "parameters": { "pointerType": 'mouse' },
      "actions": [
        {
          "type": 'pointerUp',
          "origin": 'pointer',
          "x": element.getLocation('x') - 1,
          "y": element.getLocation('y') - 1
        }
      ]
    }
  ])
}

async function setValue(browser, selector, text) {
  const input = await browser.$(selector)
  return input.setValue(text);
}

async function sendKeys(browser, selector, text) {
  const input = await browser.$(selector)
  await browser.execute(function (input) {
    input.focus();
  }, input);
  return input.keys(text)
}

async function sendEnterKey(browser, selector) {
  const input = await browser.$(selector)
  return input.keys("\uE007");
}

async function hasPreloads(browser) {
  const userdocs = await browser.execute(() => {
    return window.userdocs
  })
  if ( userdocs ) { 
    return true 
  } else { 
    return false
  }
}

function clearAnnotations(browser) {
  browser.execute(() => {
    for (let i = 0; i < window.active_annotations.length; i++) {
      document.body.removeChild(window.active_annotations[i]);
    }
    window.active_annotations = []
  })
}

async function preload(browser) {
  const functionsToPreload = [ 
    annotations, badge, styleLabel, styleBadge, styleWrapper, outline, 
    createOutlineElement, getElement, waitForElement, elementSize,
    ElementNotFound, badgeOutline
  ]

  browser.execute(() => { window.userdocs = {} })
  browser.execute(() => { window.active_annotations = [] })

  for (const func of functionsToPreload) {
    browser.execute((name, script) => {
      console.log(script)
      eval("window.userdocs." + name + " = " + script)
    }, func.name, func.toString())
  }

  return browser
}

async function scrollIntoView(browser, selector) {
  const element = await browser.$(selector)
  return element.scrollIntoView(true)
}

async function fullScreenScreenshot(browser) {
  const puppeteerBrowser = await browser.getPuppeteer()
  const pages = await puppeteerBrowser.pages()
  console.log(pages)
  let page = await currentPage(pages) 
  await page.screenshot({path: 'test-screenshot.png'});
  return browser
}

async function elementScreenshot(browser, selector, strategy) {
  const puppeteerBrowser = await browser.getPuppeteer()
  const pages = await puppeteerBrowser.pages()
  let page = await currentPage(pages) 
  if(strategy.name == 'xpath') {
    element = await page.waitForXPath(selector)
  } else if (strategy.name == 'css') {
    element = await page.$(selector);
  }
  try {
    let buffer = await element.screenshot({path: 'element-screenshot.png'});
  } catch (e) {
    console.log("Failed element screenshot")
  }
  return browser
}

async function currentPage(pages) {
  let page
  for (let i = 0; i < pages.length && !page; i++) {
      const isHidden = await pages[i].evaluate(() => document.hidden)
      if (!isHidden) {
          page = pages[i]
      }
  }
  return page
}

module.exports.closeBrowser = closeBrowser
module.exports.openBrowser = openBrowser
module.exports.navigate = navigate
module.exports.setSize = setSize
module.exports.applyAnnotation = applyAnnotation
module.exports.preload = preload
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