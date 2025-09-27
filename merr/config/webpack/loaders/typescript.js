const PnpWebpackPlugin = require('pnp-webpack-plugin')

module.exports = {
  test: /\.tsx?(\.erb)?$/,
  exclude: /node_modules/,
  use: [
    {
      loader: 'ts-loader',
      options: PnpWebpackPlugin.tsLoaderOptions()
    }
  ]
}
