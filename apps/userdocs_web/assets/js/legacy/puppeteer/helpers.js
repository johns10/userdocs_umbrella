async function currentPage(browser) {
  let page
  const pages = await browser.pages()
  for (let i = 0; i < pages.length && !page; i++) {
    const isHidden = await pages[i].evaluate(() => document.hidden)
    if (!isHidden) {
      page = pages[i]
    }
  }
  return page
}

async function getElementHandle(browser, selector, strategy) {
  const page = await currentPage(browser)
  if (strategy === 'css') {
    handles = await page.$(selector)
    return handles[0]
  } else if (strategy === 'xpath') {
    handles = await page.$x(selector)
    return handles[0]
  }
}

module.exports.currentPage = currentPage
module.exports.getElementHandle = getElementHandle