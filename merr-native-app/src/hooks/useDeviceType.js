import { useEffect, useState } from 'react';
import { DeviceType, getDeviceTypeAsync } from 'expo-device';

const useDeviceType = () => {
  const [type, setType] = useState('');
  useEffect(() => {
    (async () => {
      const deviceType = await getDeviceTypeAsync();
      setType(DeviceType[deviceType]);
    })();
  }, []);

  return {
    isMobile: type === 'PHONE',
    isTablet: type === 'TABLET',
  };
};

export default useDeviceType;
