module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$':
      '<rootDir>/assetsFileTransformer.js',
      "^.+\\.(js|jsx)$": "babel-jest"
  },
  testRegex: '.*\\.test.(ts|tsx)$',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  setupFiles: ['<rootDir>/app/javascript/test_utils/setupTests.js'],
  setupFilesAfterEnv: ['<rootDir>/app/javascript/test_utils/setupTestFramework.js'],
  // snapshotSerializers: ['enzyme-to-json/serializer'],
  // collectCoverage: true,
  // collectCoverageFrom: ['app/react/**/*.{ts,tsx}', '!app/react/__tests__/api/api-test-helpers.ts']
  moduleNameMapper: {
    '@/(.*)': '<rootDir>/app/javascript/src/$1',
    '\\.(css|scss)$': '<rootDir>/app/javascript/test_utils/styleMocks.js'
  },
  transformIgnorePatterns: ["/node_modules/(?!(react-idle-timer)/)"]
};
