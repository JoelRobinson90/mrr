/* eslint-disable max-len */
import {
  useCallback, useContext, useEffect, useRef, useState,
} from 'react';
import { AppState } from 'react-native';
import {
  addMinutes, addSeconds, isBefore, isWithinInterval,
} from 'date-fns';
import * as WebBrowser from 'expo-web-browser';
import axios from 'axios';
import {
  useAuthRequest,
  useAutoDiscovery,
  exchangeCodeAsync,
  makeRedirectUri,
} from 'expo-auth-session';

import * as Crypto from 'expo-crypto';
import Constants from 'expo-constants';
import * as SecureStore from 'expo-secure-store';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import {
  ApolloLink, concat, useApolloClient, useLazyQuery,
} from '@apollo/client';
import { AuthContext } from '../context/auth';
import GET_CURRENT_USER_QUERY from '../graphql/queries/user/currentUser';
import { httpLink } from '../graphql/client';
import Sentry from '../service/sentry';

export const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN_KEY';
export const TOKEN_EXPIRATION = 'TOKEN_EXPIRATION';
export const TOKEN_EXPIRATION_DATE = 'TOKEN_EXPIRATION_DATE';

WebBrowser.maybeCompleteAuthSession();

const { oktaUrl } = Constants.expoConfig.extra;
const { oktaClientId } = Constants.expoConfig.extra;
const { pkfcSecureString } = Constants.expoConfig.extra;
const { oktaNewDirectUrl } = Constants.expoConfig.extra;
export const OKTA_SCOPES = ['openid', 'profile', 'email', 'phone', 'offline_access'];

export async function saveSecureKey(key, value) {
  try {
    await SecureStore.setItemAsync(key, value);
    return null;
  } catch (err) {
    return null; // SecureStore will fail silently to avoid crashes
  }
}

export async function getValueFor(key) {
  try {
    const result = await SecureStore.getItemAsync(key);
    return result;
  } catch (err) {
    return null; // SecureStore will fail silently to avoid crashes
  }
}

export async function clearTokens() {
  try {
    await SecureStore.deleteItemAsync(REFRESH_TOKEN_KEY);
    await SecureStore.deleteItemAsync(TOKEN_EXPIRATION_DATE);
    return null;
  } catch (err) {
    return null; // SecureStore will fail silently to avoid crashes
  }
}

const FIELD_PROVIDER_ACCOUNT_TYPE = 'FieldProvider';
const FIELD_ADMIN_ACCOUNT_TYPE = 'FieldAdmin';
const ALLOWED_ACCOUNT_TYPES = [FIELD_PROVIDER_ACCOUNT_TYPE, FIELD_ADMIN_ACCOUNT_TYPE];

const headers = {
  Accept: 'application/json',
  'Content-Type': 'application/x-www-form-urlencoded',
};

function isValidUser(user) {
  // eslint-disable-next-line no-underscore-dangle
  return ALLOWED_ACCOUNT_TYPES.includes(user?.account?.__typename);
}

const useOktaAuth = () => {
  const [codeChallenge, setCodeChallenge] = useState();
  const [isAuthorized, setIsAuthorized] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [loginAttemptFailed, setLoginAttempFailed] = useState(false);
  const [idToken, setIdToken] = useState();
  const navigation = useNavigation();
  const [, setCurrentUser] = useContext(AuthContext);
  const appState = useRef(AppState.currentState);

  const client = useApolloClient();

  const setUserAndRedirect = (_data) => {
    setCurrentUser({
      ..._data,
      idToken,
    });
    setIsAuthorized(true);
    setLoginAttempFailed(false);
    setCodeChallenge(null);
    navigation.navigate('Dashboard');
  };

  const [getUser] = useLazyQuery(GET_CURRENT_USER_QUERY, {
    onError: () => {
      setIsLoading(false);
    },
    onCompleted: (_data) => {
      const recentUserData = _data?.getCurrentUser;

      if (isValidUser(recentUserData)) {
        setLoginAttempFailed(false);
        setUserAndRedirect(recentUserData);
      } else {
        setCurrentUser({});
        setIsAuthorized(false);
        setLoginAttempFailed(true);
      }
      setIsLoading(false);
    },
  });

  // Endpoint
  const discovery = useAutoDiscovery(`${oktaUrl}/oauth2/default`);
  // const redirectUri = `com.medarrive.medarriveapp://${oktaNewDirectUrl}`;
  const redirectUri = makeRedirectUri({
    path: oktaNewDirectUrl,
  });

  const [request, response, promptAsync] = useAuthRequest(
    {
      clientId: oktaClientId,
      scopes: OKTA_SCOPES,
      redirectUri,
      usePKCE: true,
      codeChallenge,
      codeChallengeMethod: 'S256',
    },
    discovery,
  );

  const ifTokenNeedsRefresh = async () => {
    const expDateString = await getValueFor(TOKEN_EXPIRATION_DATE);
    // if something happened with secure store skip refresh token
    if (!expDateString) return false;

    const expireDate = new Date(expDateString);

    const currentDate = new Date();
    const fifteenMinutesAgo = addMinutes(currentDate, -15);
    const closeToEnd = isWithinInterval(expireDate, { start: fifteenMinutesAgo, end: currentDate });
    // If expire datetime is previous to current date or within 15 minutes of current date.
    return isBefore(expireDate, currentDate) || closeToEnd;
  };

  // If the refresh token is present on storage then request for fetching a fresh one.
  const regenerateOktaToken = async () => {
    const refreshToken = await getValueFor(REFRESH_TOKEN_KEY);
    if (!refreshToken) return null;
    const config = {
      method: 'post',
      url: `${oktaUrl}oauth2/default/v1/token`,
      headers,
      data: {
        grant_type: 'refresh_token',
        scope: 'offline_access email openid phone profile',
        refresh_token: refreshToken,
        client_id: oktaClientId,
      },
    };

    try {
      const axiosCall = await axios(config);
      const axiosResponse = await axiosCall.data;
      const newRefreshToken = axiosResponse.refresh_token;
      const newAccessToken = axiosResponse.access_token;
      const newIdToken = axiosResponse.id_token;

      // update refresh token on secure store.
      await saveSecureKey(REFRESH_TOKEN_KEY, newRefreshToken);

      return {
        newAccessToken,
        newIdToken,
      };
    } catch (error) {
      Sentry?.Native?.captureException(error);
      return null;
    } finally {
      // If for some reason something fails, setting this to false will revert to login screen
      setIsLoading(false);
    }
  };

  // This functions updates GraphQL so it send Authorization and IDTOKEN for each request.
  const updateAuthLink = (accessToken, _idToken) => {
    let freshAccessToken = accessToken;
    let freshIdToken = _idToken;
    setIdToken(_idToken);
    const authMiddleware = new ApolloLink(async (operation, forward) => {
      // This validation is needed if the app is left open for more than 1 hour.
      const needsRefresh = await ifTokenNeedsRefresh();
      if (needsRefresh) {
        const refreshResult = await regenerateOktaToken();
        freshAccessToken = refreshResult?.newAccessToken;
        freshIdToken = refreshResult?.newIdToken;
      }

      // add the authorization to the headers
      operation.setContext({
        headers: {
          Authorization: `Bearer ${freshAccessToken}`,
          IDTOKEN: freshIdToken,
        },
      });
      // eslint-disable-next-line consistent-return
      return forward(operation);
    });

    client.setLink(concat(authMiddleware, httpLink));
  };

  // this function is triggered after authenticating with Okta on the browser successfully.
  const postAfterAuth = async (code) => {
    setIsLoading(true);

    if (!code) {
      setIsLoading(false);
      return;
    }

    try {
      const exchangeResponse = await exchangeCodeAsync(
        {
          clientId: oktaClientId,
          scopes: OKTA_SCOPES,
          code,
          redirectUri,
          extraParams: { code_verifier: request.codeVerifier },
        },
        discovery,
      );

      // ONLY saves refresh token and expiration on SecureStore.
      await saveSecureKey(REFRESH_TOKEN_KEY, exchangeResponse.refreshToken);
      await saveSecureKey(TOKEN_EXPIRATION, `${exchangeResponse.expiresIn}`);

      const currentDate = new Date();
      const newDate = addSeconds(currentDate, exchangeResponse.expiresIn);
      await saveSecureKey(TOKEN_EXPIRATION_DATE, newDate.toTimeString());

      const newAccessToken = exchangeResponse.accessToken;
      const newIdToken = exchangeResponse.idToken;

      // update access token for GraphQL
      updateAuthLink(newAccessToken, newIdToken);

      // Manually triggers refetch user for validating authorization.
      await getUser();
    } catch (error) {
      setCurrentUser({});
      setIsAuthorized(false);
    } finally {
      setIsLoading(false);
    }
  };

  // Okta authorization flow
  useFocusEffect(
    useCallback(() => {
      setCurrentUser({});
      setIsAuthorized(false);
      setLoginAttempFailed(false);

      // Only generate code digest if no response set
      if (!response) {
        (async () => {
          const digest = await Crypto.digestStringAsync(
            Crypto.CryptoDigestAlgorithm.SHA256,
            pkfcSecureString,
          );
          setCodeChallenge(digest);
        })();
      }
      // It only gets here if authentication with Okta is successful on the browser.
      if (response?.type === 'success') {
        const { code } = response.params;
        postAfterAuth(code);
      }
    }, [response]),
  );

  const refreshGraphQLToken = async () => {
    const refreshResult = await regenerateOktaToken();
    if (refreshResult?.newAccessToken && refreshResult?.newIdToken) {
      updateAuthLink(refreshResult?.newAccessToken, refreshResult?.newIdToken);
    }
  };

  // The first time it tries to load user info if not authorized it will redirect to login.
  useFocusEffect(
    useCallback(() => {
      (async () => {
        await getUser();
      })();
    }, []),
  );

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (appState.current.match(/inactive|background/) && nextAppState === 'active') {
        // App has returned from background state, trigger token refresh
        refreshGraphQLToken();
      }
      appState.current = nextAppState;
    });

    return () => {
      subscription.remove();
    };
  }, []);

  // opens browser for authenticating with Okta.
  const triggerAuthentication = async () => {
    await promptAsync({ preferEphemeralSession: true });
    return {
      redirectUri,
      oktaUrl,
      oktaClientId,
      pkfcSecureString,
    };
  };

  return {
    triggerAuthentication,
    isAuthorized,
    isLoading,
    loginAttemptFailed,
  };
};

export default useOktaAuth;
