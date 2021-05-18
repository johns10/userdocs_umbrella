const { stepInstanceHandlers } = require('../lib/automation/puppeteer/stepInstanceHandlers')
const { Puppet } = require('../lib/automation/puppet')

var browser
const url = 'https://the-internet.herokuapp.com/add_remove_elements/'
selector = "//button[contains(., 'Add Element')]"
annotationId = 1

beforeAll( async () => { 
  browser = await Puppet.openBrowser({});
  const page = (await browser.pages())[0];
  await page.goto(url);
})

//afterAll( async () => { await Puppet.closeBrowser(browser, {}); });

afterEach( async () => {
  const handler = stepInstanceHandlers["Clear Annotations"]
  await handler(browser, {})
});

test('Apply Badge Annotation', async () => {
  const stepInstance = { step: { 
    element: { selector: selector, strategy: { name: 'xpath' }}, 
    stepType: { name: 'Apply Annotation' },
    annotation: { id: annotationId, annotation_type: { name: 'Badge' }, size: 16, font_size: 24, color: 'green', x_offset: 0, y_offset: 0, x_orientation: 'M', y_orientation: 'B', label: '1' }
  } } 

  const page = (await browser.pages())[0];
  const handler = stepInstanceHandlers["Apply Annotation"]
  await handler(browser, stepInstance)
  const wrapperHandle = await page.$(`#userdocs-annotation-${annotationId}-wrapper`)
  expect(wrapperHandle).toHaveProperty('_remoteObject')
})

test('Apply Outline Annotation', async () => {
  const stepInstance = { step: { 
    element: { selector: selector, strategy: { name: 'xpath' }}, 
    stepType: { name: 'Apply Annotation' },
    annotation: { id: annotationId, annotation_type: { name: 'Outline' }, thickness: 6, color: 'green' }
  } } 

  const page = (await browser.pages())[0];
  const handler = stepInstanceHandlers["Apply Annotation"]
  await handler(browser, stepInstance)
  const wrapperHandle = await page.$(`#userdocs-annotation-${annotationId}-outline`)
  expect(wrapperHandle).toHaveProperty('_remoteObject')
})

test('Apply Blur Annotation', async () => {
  const stepInstance = { step: { 
    element: { selector: selector, strategy: { name: 'xpath' }}, 
    stepType: { name: 'Apply Annotation' },
    annotation: { id: annotationId, annotation_type: { name: 'Blur' } }
  } } 

  const page = (await browser.pages())[0];
  const handler = stepInstanceHandlers["Apply Annotation"]
  await handler(browser, stepInstance)
  const handle = (await page.$x('//button'))[0]
  expect(handle).toHaveProperty('_remoteObject')
})


test('Apply Badge Outline Annotation', async () => {
  const stepInstance = { step: { 
    element: { selector: selector, strategy: { name: 'xpath' }}, 
    stepType: { name: 'Apply Annotation' },
    annotation: { id: annotationId, annotation_type: { name: 'Badge Outline' }, thickness: 6, size: 16, font_size: 24, color: 'green', x_offset: 0, y_offset: 0, x_orientation: 'R', y_orientation: 'T', label: '1' }
  } } 

  const page = (await browser.pages())[0];
  const handler = stepInstanceHandlers["Apply Annotation"]
  await handler(browser, stepInstance)
  const wrapperHandle = await page.$(`#userdocs-annotation-${annotationId}-outline`)
  const badgeHandle = await page.$(`#userdocs-annotation-${annotationId}-badge`)
  expect(wrapperHandle).toHaveProperty('_remoteObject')
  expect(badgeHandle).toHaveProperty('_remoteObject')
})

test('Clear Annotations clears annotations', async () => {
  const stepInstance = { step: { 
    element: { selector: selector, strategy: { name: 'xpath' }}, 
    stepType: { name: 'Apply Annotation' },
    annotation: { id: annotationId, annotation_type: { name: 'Outline' }, thickness: 6, color: 'green' }
  } } 

  const page = (await browser.pages())[0];
  const annotationHandler = stepInstanceHandlers["Apply Annotation"]
  await annotationHandler(browser, stepInstance)
  const wrapperHandle = await page.$(`#userdocs-annotation-${annotationId}-outline`)
  expect(wrapperHandle).toHaveProperty('_remoteObject')
  const clearHandler = stepInstanceHandlers["Clear Annotations"]
  await clearHandler(browser, stepInstance)
  const nullHandle = await page.$(`#userdocs-annotation-${annotationId}-outline`)
  expect(nullHandle).toBeNull()
})