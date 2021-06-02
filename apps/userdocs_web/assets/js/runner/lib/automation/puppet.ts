import { Step } from '../domain/step'
import { stepHandlers } from './puppeteer/stepHandlers'
import { Runner, Configuration } from '../runner/runner'
import { Browser } from 'puppeteer'
import * as path from 'path'
import * as os from 'os'

const puppeteer = require('puppeteer')

export const Puppet = {
  stepHandler: (step: Step) => {
    var name: string
    try {
      name = step.stepType.name
    } catch(error) {
      throw new Error(`Improper step type ${step.stepType} passed to stepHandler`)
    }
    const handler = stepHandlers[name]
    if (handler) return handler
    else throw new Error(`Handler not found for ${step.stepType.name}`)
  },
  openBrowser: async(runner: Runner) => {
    var executablePath = puppeteer.executablePath()
    var args

    if(runner.environment == 'development') {
      executablePath = puppeteer.executablePath()
      args = puppeteer.defaultArgs()
        .filter(arg => String(arg).toLowerCase() !== '--disable-extensions')
        .filter(arg => String(arg).toLowerCase() !== '--headless')
        .concat("--proxy-server='direct://'")
        .concat('--proxy-bypass-list=*')
    } else if(runner.environment == 'desktop') {
      executablePath = puppeteer.executablePath().replace("app.asar", "app.asar.unpacked")
      args = puppeteer.defaultArgs()
        .filter(arg => String(arg).toLowerCase() !== '--disable-extensions')
        .filter(arg => String(arg).toLowerCase() !== '--headless')
        .concat("--proxy-server='direct://'")
        .concat('--proxy-bypass-list=*')
      if (runner.userDataDirPath) {
        args.push('--user-data-dir=' + runner.userDataDirPath);
      }
    } else if(runner.environment == 'cicd') {
      const isPkg = typeof (process as any).pkg !== 'undefined';

      executablePath = '/usr/bin/chromium-browser'

      args = puppeteer.defaultArgs()
        .concat('--single-process')
        .concat('--no-zygote')
        .concat('--no-sandbox')
    } else args = puppeteer.defaultArgs()

    console.log(args)

    const browser = await puppeteer.launch({ 
      executablePath: executablePath,
      ignoreDefaultArgs: true,
      args: args 
    });
    return browser
  },
  closeBrowser: async(browser: Browser, configuration: Configuration) => {
    await browser.close()
  }
}