import { Linking } from 'react-native';
import openExternalUrl from '../../src/helpers/openExternalUrl';

jest.mock('react-native', () => ({
  Linking: {
    canOpenURL: jest.fn(),
    openURL: jest.fn(),
  },
}));

describe('openExternalUrl', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should call Linking.canOpenURL and Linking.openURL', async () => {
    const url = 'tel://1234567890';
    Linking.canOpenURL.mockResolvedValue(true);
    await openExternalUrl('tel://', '1234567890');
    expect(Linking.canOpenURL).toHaveBeenCalledWith(url);
    expect(Linking.openURL).toHaveBeenCalledWith(url);
  });

  it('should call Linking.canOpenURL and not Linking.openURL if url cannot be opened', async () => {
    const url = '<1234567890';
    Linking.canOpenURL.mockResolvedValue(false);
    await openExternalUrl('<', '1234567890');
    expect(Linking.canOpenURL).toHaveBeenCalledWith(url);
    expect(Linking.openURL).not.toHaveBeenCalled();
  });
});
