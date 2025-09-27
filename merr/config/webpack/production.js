process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

console.log('webpack prod config', environment.toWebpackConfig())

module.exports = environment.toWebpackConfig()
