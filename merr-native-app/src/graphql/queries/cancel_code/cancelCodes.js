import { gql } from '@apollo/client';

const GET_CANCEL_CODES_QUERY = gql`
  query GetCancelCodes {
    getCancelCodes {
      id
      code
      description
    }
  }
`;

export default GET_CANCEL_CODES_QUERY;
