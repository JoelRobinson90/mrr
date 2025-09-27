import fetch from 'node-fetch';
import * as Sentry from 'sentry-expo'

global.fetch = fetch;
global.Sentry = Sentry;

jest.mock('sentry-expo', () => ({
  init: jest.fn(),
}));

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

jest.mock('expo-constants', () => ({
  expoConfig: {
    extra: {
      apiHost: '',
      graphqlHost: '',
    },
  }
}));
