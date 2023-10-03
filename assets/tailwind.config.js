module.exports = {
  content: [
    '../lib/**/*.ex',
    '../lib/**/*.heex',
    '../lib/**/*.html.heex',
    './js/**/*.js'
  ],
  important: false,
  plugins: [
    require('@tailwindcss/forms')
  ],
  theme: {
    extend: {
      borderRadius: {
        '2xl': "2rem",
        '3xl': "3rem",
        '4xl': "4rem",
        '5xl': "5rem",
        '6xl': "6rem",
        'xl': "1rem"
      },
      borderWidth: {
        '1': '1px'
      },
      boxShadow: {
        'button': '5px 5px 7px 0px rgba(0, 0, 0, 0.3)',
        'button-md': '6px 6px 2px 2px rgba(0, 0, 0, 0.3)',
        'button-sm': '4px 4px 2px 0px rgba(0, 0, 0, 0.3)',
        'button-xs': '2px 2px 2px 0px rgba(0, 0, 0, 0.3)'
      },
      fontFamily: {
        'sans': ['Montserrat-Thin', 'Helvetica', 'Arial', 'sans-serif']
      },
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
      height: {
        'screen-1/2': '50vh',
        'screen-1/20': '5vh',
        'screen-1/3': '33vh',
        'screen-1/4': '25vh',
        'screen-18/20': '90vh',
        'screen-19/20': '95vh',
        'screen-2/3': '66vh',
        'screen-3/4': '75vh'
      },
      maxHeight: {},
      minHeight: {},
      scale: {
        '80': '0.8',
        '85': '0.85',
        '98': '0.96',
        'default': '1',
        'mirror': '-1'
      },
      screens: {
        '2xl': {'max': '1920px', 'min': '1536px'},
        '3xl': {'raw': '(min-width: 1920px)'}
      },
      top: {},
      transitionDuration: {
        '1500': '1500ms',
        '1750': '1750ms',
        '2000': '2000ms',
        '2500': '2500ms',
        '3000': '3000ms'
      },
      zIndex: {
        '60': '60'
      }
    }
  },
  variants: {
    extend: {
      borderRadius: ['active', 'hover', 'focus'],
      boxShadow: ['active', 'hover', 'focus'],
      scale: ['active', 'focus-within', 'hover']
    }
  }
}
