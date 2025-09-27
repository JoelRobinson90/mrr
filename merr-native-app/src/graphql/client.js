import {
  ApolloClient,
  InMemoryCache,
  HttpLink,
} from '@apollo/client';

import Constants from 'expo-constants';

const { graphqlHost } = Constants.expoConfig.extra;

export const httpLink = new HttpLink({ uri: graphqlHost });

export const apolloCache = new InMemoryCache();

export const apolloClient = new ApolloClient({
  link: httpLink,
  cache: apolloCache,
  defaultOptions: { watchQuery: { fetchPolicy: 'cache-and-network' } },
});
