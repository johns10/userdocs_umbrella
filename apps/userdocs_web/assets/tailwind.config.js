module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.slimleex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  plugins: [
    require('daisyui')
  ],
  separator: "_"
}
