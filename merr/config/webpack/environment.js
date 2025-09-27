/* eslint @typescript-eslint/no-var-requires: 'off' */

const { environment } = require('@rails/webpacker');
const typescript = require('./loaders/typescript');
const path = require('path');

const customConfig = {
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '..', '..', 'app/javascript/src'),
    },
    extensions: ['.js', '.jsx', '.ts', '.tsx'],
    symlinks: false,
  },
};

environment.config.merge(customConfig);

environment.loaders.prepend('typescript', typescript);

environment.splitChunks();

module.exports = environment;
