module.exports = {
  darkMode: false, // or 'media' or 'class'
  important: true,
  plugins: [],
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  theme: {
    extend: {
      boxShadow: {},
      gridRow: {
        'span-10': 'span 10 / span 10',
        'span-11': 'span 11 / span 11',
        'span-12': 'span 12 / span 12',
        'span-7': 'span 7 / span 7',
        'span-8': 'span 8 / span 8',
        'span-9': 'span 9 / span 9'
      },
      gridRowEnd: {
        '10': '10',
        '11': '11',
        '12': '12',
        '7': '7',
        '8': '8',
        '9': '9'
      },
      gridRowStart: {
        '10': '10',
        '11': '11',
        '12': '12',
        '7': '7',
        '8': '8',
        '9': '9'
      },
      height: {},
      maxHeight: {},
      minHeight: {},
      top: {},
      transitionDuration: {
        '1500': '1500ms',
        '1750': '1750ms',
        '2000': '2000ms',
        '2500': '2500ms',
        '3000': '3000ms'
       }
    },
    fontFamily: {
      'sans': ['Helvetica', 'Arial', 'sans-serif']
    },
    zIndex: {}
  },
  variants: {
    extend: {
      scale: ['focus-within']
    }
  }
}
