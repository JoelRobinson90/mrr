/* eslint @typescript-eslint/no-var-requires: 'off' */

process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');

module.exports = environment.toWebpackConfig();
