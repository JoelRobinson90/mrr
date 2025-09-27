require('dotenv').config();

const projectId = 'b94d921e-6250-4315-9a26-826eeba5304f';

const graphqlHost = process.env.APP_ENV === 'stage'
  ? 'https://stage-web.medarrive.com/graphql_jwt'
  : process.env.GRAPHQL_HOST;

const configEnv = process.env.APP_ENV === 'production'
  ? {
    apiUrl: process.env.API_URL_PROD,
    oktaUrl: process.env.OKTA_URL_PROD,
    oktaClientId: process.env.OKTA_CLIENT_ID_PROD,
    oktaRedirect: process.env.OKTA_REDIRECT_PROD,
    graphqlHost: process.env.GRAPHQL_HOST_PROD,
    sentryEnableNative: true,
    oktaNewDirectUrl: process.env.OKTA_NEW_REDIRECT_URL_PROD,
  }
  : {
    apiUrl: process.env.API_URL,
    oktaUrl: process.env.OKTA_URL,
    oktaClientId: process.env.OKTA_CLIENT_ID,
    oktaRedirect: process.env.OKTA_REDIRECT,
    graphqlHost,
    sentryEnableNative: false,
    oktaNewDirectUrl: process.env.OKTA_NEW_REDIRECT_URL,
  };

module.exports = ({ config }) => ({
  ...config,
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.medarrive.medarriveapp',
    buildNumber: '6',
    infoPlist: {
      NSLocationWhenInUseUsageDescription:
        'We need your location for safety reasons to ensure we know the location of our field providers while they are in the field and in patient homes.',
      LSApplicationQueriesSchemes: ['sms'],
    },
    // UNCOMMENT FOR BACKGROUND LOCATION
    // infoPlist: {
    //   UIBackgroundModes: [
    //     'location',
    //     'fetch',
    //   ],
    // },
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#FFFFFF',
    },
    package: 'com.medarrive.medarriveapp',
    // UNCOMMENT FOR BACKGROUND LOCATION
    // permissions: [
    //   'ACCESS_BACKGROUND_LOCATION',
    // ],
    config: {
      googleMaps: {
        apiKey: 'AIzaSyB_RHZwm8udztZfYKKf9LDLsp-w0qfagqY',
      },
    },
  },
  extra: {
    ...configEnv,
    sentryEnvironment: process.env.APP_ENV,
    pkfcSecureString: process.env.PKFC_SECURE_STRING,
    sentryDsn: process.env.SENTRY_DSN,
    eas: {
      projectId,
    },
  },
  plugins: ['sentry-expo', 'expo-localization'],
  hooks: {
    postPublish: [
      {
        file: 'sentry-expo/upload-sourcemaps',
        config: {
          organization: process.env.SENTRY_ORG,
          project: 'react-native',
        },
      },
    ],
  },
  updates: {
    url: 'https://u.expo.dev/b94d921e-6250-4315-9a26-826eeba5304f',
    fallbackToCacheTimeout: 0,
    enabled: true,
    checkAutomatically: 'ON_LOAD',
  },
  runtimeVersion: {
    policy: 'sdkVersion',
  },
});
