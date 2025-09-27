# Medarrive Native App

Created with Expo framework.

## Prerequisites
- Install Expo CLI `npm install -g expo-cli`
- Install EAS CLI `npm install -g eas-cli`
- Use nvm for easy node version management.
- `nvm install 16.18.0`
- `nvm use`

## Node version
- v18.15.0

## Setup
- Make sure to install expo cli.
- Copy `.env-example` into `.env`
- yarn install
- Open iOS simulator or Android emulator.

## Expo Go
- You need to be added to Medarrive expo organization for being able to test the app with Expo Go.
- PR reviewing: Each PR generates a QR code that you can scan with Expo Go so you can easily test changes without having to pull changes and compile locally.

### Helpful Links

#### Expo
- Expo Medarrive Dashboard https://expo.dev/accounts/medarrive

#### Expo commands
- `npx expo start` run project
- `npx expo start -c` run project clean cache
- `npx expo install --fix` fix installation
- `npx expo-doctor` review project
- `npx expo run:android or npx expo android` or `npx expo run:ios or npx expo ios` run native project
- `npx expo start --no-dev --minify` or `yarn prod-mode` run production mode

#### Expo Test your changes locally on your development build https://docs.expo.dev/development/create-development-builds/
- `npx expo start --dev-client`

- run `npm run test`

#### Okta
- Medarrive Okta Integration Native App: https://medarrive-sandbox-admin.oktapreview.com/admin/app/oidc_client/instance/0oa5w7siul0MQvcIC1d7/#tab-general
- Okta auth Expo example https://docs.expo.dev/guides/authentication/#okta

#### OTA command to publish
- Prod: `expo publish --release-channel production`
- Test: `expo publish --release-channel`

## Configuring EAS Submit

- https://docs.expo.dev/submit/eas-json/
- Create serviceaccountkeypath for EAS-Submit-Android https://github.com/expo/fyi/blob/main/creating-google-service-account.md


