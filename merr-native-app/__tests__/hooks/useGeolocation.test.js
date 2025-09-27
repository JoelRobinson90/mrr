import { renderHook, act } from '@testing-library/react-hooks';
import { useFocusEffect } from '@react-navigation/native';
import * as Location from 'expo-location';

import useGeolocation from '../../src/hooks/useGeolocation';

jest.mock('expo-location', () => {
  const original = jest.requireActual('expo-location');
  return {
    ...original,
    getForegroundPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted', canAskAgain: true }),
    getCurrentPositionAsync: jest.fn().mockResolvedValue({ coords: { latitude: '10', longitude: '10' } }),
    requestForegroundPermissionsAsync: jest.fn().mockResolvedValue({
      ios: 'whenInUse',
      android: 'coarse',
    }),
    watchPositionAsync: jest.fn(),
    getBackgroundPermissionsAsync: jest.fn().mockResolvedValue({ granted: true }),
    hasStartedLocationUpdatesAsync: jest.fn().mockResolvedValue(true),
    startLocationUpdatesAsync: jest.fn(),
    stopLocationUpdatesAsync: jest.fn(),
    Accuracy: jest.fn().mockResolvedValue({
      Accuracy: { BestForNavigation: 6 },
    }),
  };
});

jest.mock('expo-task-manager', () => {
  const original = jest.requireActual('expo-task-manager');
  return {
    ...original,
    isTaskDefined: jest.fn().mockResolvedValue(true),
  };
});

jest.mock('@react-navigation/native', () => ({
  useFocusEffect: jest.fn(),
}));

describe('useGeolocation', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should return coords, isLocationGranted as true, and permissionDenied as false', async () => {
    const { result } = renderHook(() => useGeolocation());

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    await act(async () => {
      result.current.requestPermissions();
    });

    expect(result.current.isLocationGranted).toBe(true);
    expect(result.current.permissionDenied).toBe(false);
    expect(result.current.location).toMatchObject({ coords: { latitude: '10', longitude: '10' } });
  });

  it('should return coords as null, isLocationGranted as false and permissionDenied as true', async () => {
    Location.getForegroundPermissionsAsync.mockResolvedValue({ status: 'denied', canAskAgain: false });

    const { result } = renderHook(() => useGeolocation());

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    await act(async () => {
      result.current.requestPermissions();
    });

    expect(result.current.isLocationGranted).toBe(false);
    expect(result.current.permissionDenied).toBe(true);
    expect(result.current.location).toBeNull();
  });
});
