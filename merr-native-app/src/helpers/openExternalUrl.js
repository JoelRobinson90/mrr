import { Linking } from 'react-native';

import Sentry from '../service/sentry';

const openExternalUrl = async (path, phoneNumber) => {
  const url = phoneNumber ? `${path}${phoneNumber}` : '';

  try {
    const canOpenURL = await Linking.canOpenURL(url);
    if (canOpenURL) await Linking.openURL(url);
  } catch (error) {
    Sentry?.Native?.captureException(error);
  }
};

export default openExternalUrl;
