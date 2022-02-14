const { sassPlugin } = require('esbuild-sass-plugin')
const autoprefixer = require('autoprefixer')
const esbuild = require('esbuild')
const path = require('path')
const postcss = require('postcss')
const postcssPresetEnv = require('postcss-preset-env')
const tailwindcss = require('tailwindcss')

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
  '.png': 'file',
  '.svg': 'file'
}

const plugins = [
  // Add and configure plugins here
  sassPlugin({
    async transform(source) {
      const { css } = await postcss(
        [
          autoprefixer,
          postcssPresetEnv({stage: 0}),
          tailwindcss(path.resolve(__dirname, "./tailwind.config.js"))
        ]
      ).process(source)
      return css
    }
  })
  // {
  //   name: 'copy-files',
  //   setup(build) {
  //     // Redirect all paths starting with "images/" to "./public/images/"
  //     build.onResolve({ filter: /^images\// }, args => {
  //       return { path: path.join(args.resolveDir, 'public', args.path) }
  //     })

  //     // Redirect all paths starting with "svg/" to "./public/svg/"
  //     build.onResolve({ filter: /^svg\// }, args => {
  //       return { path: path.join(args.resolveDir, 'public', args.path) }
  //     })
  //   }
  // }
]

let opts = {
  bundle: true,
  entryPoints: ['js/app.js', 'css/app.scss'],
  external: [
    './static/images/*',
    './static/svg/*'
  ],
  loader,
  logLevel: 'info',
  outdir: '../priv/static/',
  plugins,
  target: 'es2017'
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: 'inline',
    watch
  }
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  }
}

const promise = esbuild.build(opts)

if (watch) {
  promise.then(() => {
    process.stdin.on('close', () => {
      process.exit(0)
    })

    process.stdin.resume()
  })
}
