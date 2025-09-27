import { renderHook } from '@testing-library/react-hooks';
import { getDeviceTypeAsync, DeviceType } from 'expo-device';
import useDeviceType from '../../src/hooks/useDeviceType';

jest.mock('expo-device', () => ({
  getDeviceTypeAsync: jest.fn(),
  DeviceType: {
    PHONE: 'PHONE',
    TABLET: 'TABLET',
  },
}));

describe('useDeviceType', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should return correct values for mobile device', async () => {
    getDeviceTypeAsync.mockResolvedValue(DeviceType.PHONE);

    const { result, waitFor } = renderHook(() => useDeviceType());

    await waitFor(() => {
      expect(result.current.isMobile).toBe(true);
      expect(result.current.isTablet).toBe(false);
    });
  });

  it('should return correct values for tablet device', async () => {
    getDeviceTypeAsync.mockResolvedValue(DeviceType.TABLET);

    const { result, waitFor } = renderHook(() => useDeviceType());

    await waitFor(() => {
      expect(result.current.isMobile).toBe(false);
      expect(result.current.isTablet).toBe(true);
    });
  });
});
