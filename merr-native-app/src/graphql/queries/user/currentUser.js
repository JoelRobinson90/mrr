import { gql } from '@apollo/client';

const GET_CURRENT_USER_QUERY = gql`
  query {
    getCurrentUser {
      id
      email
      displayName
      account {
        ... on FieldProvider {
          id
          firstName
          lastName
        }
      }
    }
  }
`;

export default GET_CURRENT_USER_QUERY;
