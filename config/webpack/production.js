process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

// Add production-specific optimizations
environment.config.merge({
  optimization: {
    minimize: true,
    nodeEnv: 'production',
    concatenateModules: true,
    sideEffects: false
  },
  performance: {
    hints: false, // Disable performance hints to avoid warnings in build
    maxAssetSize: 500000,
    maxEntrypointSize: 500000
  },
  stats: {
    errorDetails: true,
    colors: false,
    hash: false,
    timings: false,
    assets: false,
    chunks: false,
    chunkModules: false,
    modules: false,
    children: false
  }
})

// Increase memory limit for asset compilation
if (process.env.NODE_OPTIONS && !process.env.NODE_OPTIONS.includes('max-old-space-size')) {
  process.env.NODE_OPTIONS = `${process.env.NODE_OPTIONS} --max-old-space-size=4096`
}

module.exports = environment.toWebpackConfig()
