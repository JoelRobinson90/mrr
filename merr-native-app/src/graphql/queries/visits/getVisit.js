import { gql } from '@apollo/client';
import { VISIT_FIELDS_FRAGMENT } from '../fragments';

const GET_VISIT_QUERY = gql`
  ${VISIT_FIELDS_FRAGMENT}
  query GetVisit($id: ID) {
    getVisit(id: $id) {
      ...VisitFields
    }
  }
`;

export default GET_VISIT_QUERY;
