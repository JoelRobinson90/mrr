/* eslint @typescript-eslint/no-var-requires: 'off' */
const enzyme = require('enzyme');
const Adapter = require('enzyme-adapter-react-16');
require('jest-canvas-mock');

enzyme.configure({ adapter: new Adapter() });
