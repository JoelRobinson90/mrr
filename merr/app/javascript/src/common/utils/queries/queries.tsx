import queryString, { StringifiableRecord } from 'query-string';

export const getCurrentQuery = (): StringifiableRecord => queryString.parse(window.location.search);

// Parses current URL for existing query string
// and returns new URL with updated query string
// Any null values are removed
export const getUpdatedQueryPath = (newParams: StringifiableRecord = {}): string => {
  const updatedParams = { ...getCurrentQuery(), ...newParams };
  return queryString.stringifyUrl({ url: window.location.pathname, query: updatedParams }, { skipNull: true });
};
