const data = require('./testJob.json')
const { iterate } = require('../lib/runner/iterate')
const { Puppet } = require('../lib/automation/puppet')
const { query } = require('../query.ts')
const { authenticate } = require('../auth.ts')
const { job } = require('../queries.ts')
require('dotenv').config()

var browser
beforeAll( async () => { browser = await Puppet.openBrowser({}); });
afterAll( async () => { await Puppet.closeBrowser(browser, {}); });

auth_url = 'https://' + process.env.DEV_HOST + ':' + process.env.DEV_PORT  + '/api/session'
api_url = 'https://' + process.env.DEV_HOST + ':' + process.env.DEV_PORT  + '/api'
auth_params = { authUrl: auth_url, email: 'johns10davenport@gmail.com', password: 'userdocs'}
/*
test('query returns a result', async () => {
  configuration = { 
    automationFramework: Puppet,
    browser: browser,
    imagePath: "./images",
    maxRetries: 2
  }
  const tokens = await authenticate(auth_params)
  const queryText = job(1)
  response = await query.execute(api_url, tokens, queryText);
  const completedJob = await iterate(response.job, "execute", configuration)
})
*/