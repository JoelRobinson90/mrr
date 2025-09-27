import React from 'react';
import { renderHook, act } from '@testing-library/react-hooks';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import { AuthContext } from '../../src/context/auth';
import useCheckValidAuth from '../../src/hooks/useCheckValidAuth';
import { clearTokens } from '../../src/hooks/useOktaAuth';

const mockSetCurrentUser = jest.fn();
const mockNavigation = { navigate: jest.fn() };
const clearTokensMock = clearTokens;
let graphqlError = { message: 'User not authenticated' };

jest.mock('../../src/hooks/useOktaAuth', () => ({
  clearTokens: jest.fn(),
}));

jest.mock('@react-navigation/native', () => ({
  useFocusEffect: jest.fn(),
  useNavigation: jest.fn(),
}));

describe('useCheckValidAuth', () => {
  beforeEach(() => {
    useNavigation.mockReturnValue(mockNavigation);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should clear tokens, set currentUser to null, and navigate to Home screen when there is a graphqlError with "not authenticated" message', async () => {
    const navigateSpy = jest.spyOn(mockNavigation, 'navigate');

    renderHook(() => useCheckValidAuth(graphqlError), {
      wrapper: ({ children }) => (
        <AuthContext.Provider value={[null, mockSetCurrentUser]}>
          {children}
        </AuthContext.Provider>
      ),
    });

    expect(useFocusEffect).toHaveBeenCalledTimes(1);

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    expect(clearTokensMock).toHaveBeenCalledTimes(1);
    expect(mockSetCurrentUser).toHaveBeenCalledTimes(1);
    expect(mockSetCurrentUser).toHaveBeenCalledWith(null);
    expect(navigateSpy).toHaveBeenCalledTimes(1);
    expect(navigateSpy).toHaveBeenCalledWith('Home');
  });

  it('should not clear tokens or navigate to Home screen when there is no graphqlError', async () => {
    const navigateSpy = jest.spyOn(mockNavigation, 'navigate');
    graphqlError = null;

    renderHook(() => useCheckValidAuth(graphqlError), {
      wrapper: ({ children }) => (
        <AuthContext.Provider value={[null, mockSetCurrentUser]}>
          {children}
        </AuthContext.Provider>
      ),
    });

    expect(useFocusEffect).toHaveBeenCalledTimes(1);

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    expect(clearTokensMock).not.toHaveBeenCalled();
    expect(mockSetCurrentUser).not.toHaveBeenCalled();
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
