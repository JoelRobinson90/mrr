import { gql, makeVar } from '@apollo/client';

export interface Filter {
  id: string;
  key: string;
  value: string | [] | boolean;
}

export type Filters = Filter[];

// Accessing localStorage in an iframe throws a security error, so we do a check first
const isLocalStorageAvailable = () => {
  const test = 'local_storage_access_test';
  try {
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch (e) {
    return false;
  }
};

const cachedFilters = isLocalStorageAvailable() ? JSON.parse(localStorage.getItem('filters')) : [];
export const filtersVar = makeVar<Filters>(cachedFilters);

export const localTypeDefs = gql`
  extend type Query {
    isLoggedIn: Boolean!
  }
`;

export const GET_ALL_FILTERS = gql`
  query GetAllFilters {
    filters @client {
      id
      key
      value
    }
  }
`;

const cache = {
  typePolicies: {
    Query: {
      fields: {
        filters: {
          read() {
            return filtersVar();
          },
        },
      },
    },
  },
};

export default cache;
