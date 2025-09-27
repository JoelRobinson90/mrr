const custom = require('../config/webpack/development')

module.exports = {
  "stories": [
    "../stories/**/*.stories.mdx",
    "../stories/**/*.stories.@(js|jsx|ts|tsx)"
  ],
  "addons": [
    "@storybook/addon-links",
    "@storybook/addon-essentials"
  ],
  webpackFinal: (config) => {
    return {
      ...config,
      resolve: {
        ...config.resolve,
        ...custom.resolve,
      }
      // module: { ...config.module, } }
    }
  }
}
