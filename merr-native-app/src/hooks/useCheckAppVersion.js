import { checkForUpdateAsync, fetchUpdateAsync } from 'expo-updates';
import { AppState } from 'react-native';
import { useEffect, useRef } from 'react';

import Sentry from '../service/sentry';

const useCheckAppVersion = () => {
  const appState = useRef(AppState.currentState);

  const checkAndSilentlyUpdate = async () => {
    try {
      const update = await checkForUpdateAsync();

      if (update.isAvailable) {
        await fetchUpdateAsync();
      }
    } catch (error) {
      Sentry?.Native?.captureException(error);
    }
  };

  checkAndSilentlyUpdate();

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (
        appState.current.match(/inactive|background/)
        && nextAppState === 'active'
      ) {
        checkAndSilentlyUpdate();
      }

      appState.current = nextAppState;
    });

    return () => {
      subscription.remove();
    };
  }, []);
};

export default useCheckAppVersion;
