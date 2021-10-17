module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.slimleex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  plugins: [
    require('@tailwindcss/typography'),
    require('daisyui'),
  ],
  separator: "_",
  theme: {
    maxWidth: {
      '25': '25%',
      '33': '33%',
      '50': '50%',
      '75': '75%'
    },
    extend: {
      transitionProperty: {
        'width': 'width'
      }
    }
  }
}
