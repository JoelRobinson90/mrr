import React from 'react';
import { renderHook, act } from '@testing-library/react-hooks';
import { useFocusEffect } from '@react-navigation/native';

import { exchangeCodeAsync } from 'expo-auth-session';

import useOktaAuth from '../../src/hooks/useOktaAuth';

const mockedUsedNavigate = jest.fn();

jest.mock('@apollo/client', () => ({
  useApolloClient: () => ({
    setLink: jest.fn().mockReturnValue({}),
  }),
  gql: jest.fn(),
  HttpLink: jest.fn().mockImplementation(() => ({
    request: jest.fn(),
  })),
  InMemoryCache: jest.fn(),
  ApolloClient: jest.fn(),
  ApolloLink: jest.fn().mockReturnValue({}),
  concat: jest.fn().mockReturnValue({}),
  useLazyQuery: jest.fn().mockImplementation(() => ([async () => 'getUser'])),
}));

jest.mock('expo-auth-session', () => ({
  exchangeCodeAsync: jest.fn(),
  makeRedirectUri: jest.fn().mockReturnValue('makeRedirectUri'),
  useAutoDiscovery: jest.fn().mockReturnValue('link'),
  useAuthRequest: jest.fn().mockReturnValue([
    {
      codeVerifier: 1234,
    }, {
      type: 'success',
      params: {
        code: 123,
      },
    }, async () => {},
  ]),
}));

jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useFocusEffect: jest.fn(),
    useNavigation: () => ({
      navigate: mockedUsedNavigate,
    }),
  };
});

describe('useOktaAuth', () => {
  beforeAll(() => {
    jest.spyOn(React, 'useContext').mockImplementation(() => ['currentUser', jest.fn()]);
    exchangeCodeAsync.mockReturnValue({
      refreshToken: 'refreshToken',
      expiresIn: 10,
      accessToken: 'accessToken',
      idToken: 'idToken',
    });
  });

  afterAll(() => {
    React.useContext.mockRestore();
    jest.clearAllMocks();
  });

  it('should the user be authorized', async () => {
    jest.spyOn(React, 'useState').mockReturnValueOnce(['', jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([true, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([false, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([false, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce(['', jest.fn()]);

    const { result } = renderHook(() => useOktaAuth());

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    await act(async () => {
      result.current.triggerAuthentication();
    });

    expect(result.current.isAuthorized).toBe(true);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.loginAttemptFailed).toBe(false);
  });

  it("Shouldn't the user be authorized", async () => {
    jest.spyOn(React, 'useState').mockReturnValueOnce(['', jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([false, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([false, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce([true, jest.fn()]);
    jest.spyOn(React, 'useState').mockReturnValueOnce(['', jest.fn()]);

    const { result } = renderHook(() => useOktaAuth());

    await act(async () => {
      useFocusEffect.mock.calls[0][0]();
    });

    await act(async () => {
      result.current.triggerAuthentication();
    });

    expect(result.current.isAuthorized).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.loginAttemptFailed).toBe(true);
  });
});
