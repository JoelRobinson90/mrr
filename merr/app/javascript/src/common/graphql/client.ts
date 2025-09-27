import { ApolloClient, HttpLink, InMemoryCache, from, ApolloLink } from '@apollo/client';
import { onError } from '@apollo/client/link/error';
import fetch from 'cross-fetch';
import cache, { localTypeDefs } from './cache';

import { new_user_session_path } from '@/common/routes';

const csrfToken = document.querySelector('meta[name=csrf-token]')?.getAttribute('content');

const tempAuthToken = document.querySelector('meta[name=temp-auth-token]')?.getAttribute('content');

const authMiddleware = new ApolloLink((operation, forward) => {
  if (window.MedArrive?.activeJwt) {
    operation.setContext(({ headers = {} }) => {
      return {
        headers: {
          ...headers,
          authorization: `Bearer ${window.MedArrive?.activeJwt}`,
        },
      };
    });
  }

  return forward(operation);
});

const errorLink = onError(({ graphQLErrors, networkError }) => {
  const networkErrorString = networkError ? networkError.toString() : '';
  if (graphQLErrors)
    graphQLErrors.forEach(({ message, locations, path }) =>
      console.log(`[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`),
    );

  if (networkErrorString.includes('401') || networkErrorString.includes('422')) {
    location.assign(new_user_session_path());
  }
});

export type GraphlClientOptions = {
  uri?: string;
};

const DEFAULT_GRAPHQL_CLIENT_OPTIONS = {
  uri: '/graphql',
};

export const graphqlClient = (options: GraphlClientOptions | undefined = {}) => {
  options = { ...DEFAULT_GRAPHQL_CLIENT_OPTIONS, ...options };
  const { uri } = options;

  const httpLink = new HttpLink({
    fetch,
    uri,
    credentials: 'same-origin',
    headers: {
      'X-CSRF-Token': csrfToken,
      'X-Temp-Auth-Token': tempAuthToken,
    },
  });

  return new ApolloClient({
    cache: new InMemoryCache(cache),
    link: from([authMiddleware, errorLink, httpLink]),
    typeDefs: localTypeDefs,
  });
};
