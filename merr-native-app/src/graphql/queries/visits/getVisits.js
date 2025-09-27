import { gql } from '@apollo/client';
import { VISIT_FIELDS_FRAGMENT } from '../fragments';

const GET_VISITS_QUERY = gql`
  ${VISIT_FIELDS_FRAGMENT}
  query GetVisits($start_time: String, $end_time: String, $limit: Int) {
    getVisits(startTime: $start_time, endTime: $end_time, limit: $limit) {
      ...VisitFields
    }
  }
`;

export default GET_VISITS_QUERY;
