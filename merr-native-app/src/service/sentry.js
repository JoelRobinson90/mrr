import * as Sentry from 'sentry-expo';
import Constants from 'expo-constants';

/*
In order to test locally with sentry, it is necessary to run the project
with the command `npx expo run:android or npx expo android` or `npx expo
run:ios or npx expo ios` and uncomment the line enableInExpoDevelopment
*/

Sentry.init({
  dsn: Constants.manifest?.extra?.sentryDsn,
  // enableInExpoDevelopment: true,
  tracesSampleRate: 1.0,
  debug: false,
  environment: Constants.manifest?.extra?.sentryEnvironment,
  enableNative: Constants.manifest?.extra?.sentryEnableNative,
  autoInitializeNativeSdk: Constants.manifest?.extra?.sentryEnableNative,
});

export const sentryCaptureException = (error, userInfo) => {
  if (userInfo) {
    const { email, displayName } = userInfo;
    Sentry.Native.setUser({
      username: displayName,
      email,
    });
  }
  Sentry?.Native?.captureException(error);
};

export default Sentry;
