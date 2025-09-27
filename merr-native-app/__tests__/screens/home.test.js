import React from 'react';
import * as WebBrowser from 'expo-web-browser';

import {
  renderWithProviders, fireEvent, act, cleanup,
} from '../../src/helpers/testingLibrary';
import HomeScreen from '../../src/screens/home/home';

import useOktaAuth from '../../src/hooks/useOktaAuth';
import useLoadingFonts from '../../src/hooks/useLoadingFonts';

const mockTriggerAuthentication = jest.fn();

// eslint-disable-next-line react/prop-types
jest.mock('../../src/components/FullScreenLoading.jsx', () => function FullScreenLoadingMock({ children }) {
  return <div>{children}</div>;
});

jest.mock('../../src/hooks/useLoadingFonts', () => ({
  __esModule: true,
  default: jest.fn(),
}));

jest.mock('../../src/hooks/useOktaAuth', () => ({
  __esModule: true,
  default: jest.fn(),
}));

jest.mock('expo-web-browser', () => ({
  openBrowserAsync: jest.fn(),
}));

describe('HomeScreen', () => {
  beforeEach(() => {
    useLoadingFonts.mockReturnValue({
      fontsLoaded: true,
    });
    useOktaAuth.mockReturnValue({
      triggerAuthentication: mockTriggerAuthentication,
      isLoading: false,
      loginAttemptFailed: false,
    });
    WebBrowser.openBrowserAsync.mockImplementationOnce(() => Promise.resolve());
  });

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('should render correctly', async () => {
    const { getByText } = renderWithProviders(<HomeScreen />);
    expect(getByText('Log in')).toBeDefined();
    expect(getByText("By tapping Log in you agree to Medarrive's")).toBeDefined();
    expect(getByText('Terms & Conditions')).toBeDefined();
    expect(getByText('Privacy Policy')).toBeDefined();
  });

  it('should trigger authentication on button press', () => {
    const { getByText } = renderWithProviders(<HomeScreen />);
    act(() => {
      fireEvent.press(getByText('Log in'));
    });
    expect(mockTriggerAuthentication).toHaveBeenCalled();
  });

  it('should navigate to "Terms & Conditions" link', () => {
    const { getByText } = renderWithProviders(<HomeScreen />);
    act(() => {
      fireEvent.press(getByText('Terms & Conditions'));
    });
    expect(WebBrowser.openBrowserAsync).toHaveBeenCalledWith('https://www.medarrive.com/mobile-terms-of-service');
  });

  it('should navigate to "Privacy Policy" link', () => {
    const { getByText } = renderWithProviders(<HomeScreen />);

    act(() => {
      fireEvent.press(getByText('Privacy Policy'));
    });
    expect(WebBrowser.openBrowserAsync).toHaveBeenCalledWith('https://www.medarrive.com/privacy-policy');
  });

  it('should "Error authenticating please try again" message', () => {
    const { getByText, queryByText } = renderWithProviders(<HomeScreen />);

    expect(queryByText('Error authenticating please try again')).toBeNull();

    act(() => {
      fireEvent.press(getByText('Log in'));
    });

    useOktaAuth.mockReturnValue({
      loginAttemptFailed: true,
    });

    expect(queryByText('Error authenticating please try again')).toBeDefined();
  });
});
