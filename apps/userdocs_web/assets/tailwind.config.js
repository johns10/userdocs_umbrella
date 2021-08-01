module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.slimleex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
  separator: "_"
}
