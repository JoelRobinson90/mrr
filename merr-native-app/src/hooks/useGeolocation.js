import { useFocusEffect } from '@react-navigation/native';
import * as Location from 'expo-location';
import * as TaskManager from 'expo-task-manager';
import {
  useCallback, useEffect, useState, useRef,
} from 'react';
import { AppState, Alert } from 'react-native';

const LOCATION_TASK_NAME = 'LOCATION_TASK_NAME';
let foregroundSubscription = null;
// Define the background task for location tracking
// UNCOMMENT THIS WHENEVER WE NEED TO TRACK LOCATION ON BACKGROUND
// TaskManager.defineTask(LOCATION_TASK_NAME, async ({ data, error }) => {
//   if (error) {
//     console.error(error);
//     return;
//   }
//   if (data) {
//     // Extract location coordinates from data
//     const { locations } = data;
//     const location = locations[0];
//     if (location) {
//       // console.log('Location in background', location.coords);
//     }
//   }
// });

const useGeolocation = () => {
  const [location, setLocation] = useState(null);
  const [isLocationGranted, setIsLocationGranted] = useState(false);
  const [permissionDenied, setPermissionDenied] = useState(false);
  const [alertMenssage, setAlertMenssage] = useState(false);
  const appState = useRef(AppState.currentState);

  const checkPermissionsEnabled = async () => {
    const permission = await Location.getForegroundPermissionsAsync();
    return permission.status === 'granted';
  };

  const requestPermissions = async () => {
    try {
      const permission = await Location.getForegroundPermissionsAsync();
      if (!permission.canAskAgain) {
        setPermissionDenied(true);
      } else if (permission.status === 'granted') {
        setIsLocationGranted(true);
        setPermissionDenied(false);
        const loc = await Location.getCurrentPositionAsync({});
        setLocation(loc);
      } else {
        const foreground = await Location.requestForegroundPermissionsAsync();
        if (foreground.granted) {
          // ENABLE IF BACKGROUND LOCATION NEEDED
          // await Location.requestBackgroundPermissionsAsync();
          setIsLocationGranted(true);
          const loc = await Location.getCurrentPositionAsync({});
          setLocation(loc);
        } else {
          setIsLocationGranted(false);
        }
      }
    } catch {
      if (!alertMenssage) {
        Alert.alert('You need to enable location sharing', '', [
          { text: 'OK', onPress: () => setAlertMenssage(true) },
        ]);
      }
    }
  };

  const checkPermissionsAndPrompt = async () => {
    const granted = await checkPermissionsEnabled();
    if (granted) {
      requestPermissions();
    } else {
      setIsLocationGranted(false);
    }
  };

  useFocusEffect(useCallback(() => {
    checkPermissionsAndPrompt();
    if (alertMenssage) setAlertMenssage(false);
  }, [alertMenssage]));

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (appState.current.match(/inactive|background/) && nextAppState === 'active') {
        // App has returned from background state, check permission location
        checkPermissionsAndPrompt();
      }
      appState.current = nextAppState;
    });

    return () => {
      subscription.remove();
    };
  }, []);

  // Start location tracking in foreground
  const startForegroundUpdate = async () => {
    // Check if foreground permission is granted
    const { granted } = await Location.getForegroundPermissionsAsync();
    if (!granted) {
      console.log('location tracking denied');
      return;
    }

    // Make sure that foreground location tracking is not running
    foregroundSubscription?.remove();

    // Start watching position in real-time
    foregroundSubscription = await Location.watchPositionAsync(
      {
        // For better logs, we set the accuracy to the most sensitive option
        accuracy: Location.Accuracy.BestForNavigation,
      },
      (_location) => {
        setLocation(_location.coords);
      },
    );
  };

  // Stop location tracking in foreground
  const stopForegroundUpdate = () => {
    foregroundSubscription?.remove();
    setLocation(null);
  };

  // Start location tracking in background
  const startBackgroundUpdate = async () => {
    // Don't track position if permission is not granted
    const { granted } = await Location.getBackgroundPermissionsAsync();
    if (!granted) {
      console.log('location tracking denied');
      return;
    }

    // Make sure the task is defined otherwise do not start tracking
    const isTaskDefined = await TaskManager.isTaskDefined(LOCATION_TASK_NAME);
    if (!isTaskDefined) {
      console.log('Task is not defined');
      return;
    }

    // Don't track if it is already running in background
    const hasStarted = await Location.hasStartedLocationUpdatesAsync(
      LOCATION_TASK_NAME,
    );
    if (hasStarted) {
      console.log('Already started');
      return;
    }

    await Location.startLocationUpdatesAsync(LOCATION_TASK_NAME, {
      // For better logs, we set the accuracy to the most sensitive option
      accuracy: Location.Accuracy.BestForNavigation,
      // Make sure to enable this notification if you want to consistently track in the background
      showsBackgroundLocationIndicator: true,
      foregroundService: {
        notificationTitle: 'Location',
        notificationBody: 'Location tracking in background',
        notificationColor: '#fff',
      },
    });
  };

  // Stop location tracking in background
  const stopBackgroundUpdate = async () => {
    const hasStarted = await Location.hasStartedLocationUpdatesAsync(
      LOCATION_TASK_NAME,
    );
    if (hasStarted) {
      await Location.stopLocationUpdatesAsync(LOCATION_TASK_NAME);
      console.log('Location tacking stopped');
    }
  };

  return {
    location,
    isLocationGranted,
    permissionDenied,
    requestPermissions,
    startForegroundUpdate,
    stopForegroundUpdate,
    startBackgroundUpdate,
    stopBackgroundUpdate,
  };
};

export default useGeolocation;
