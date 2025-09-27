import { gql } from '@apollo/client';
import { NOTE_FRAGMENT } from '../fragments';

const GET_VISIT_NOTES_QUERY = gql`
  ${NOTE_FRAGMENT}
  query GetVisitNotes($notable_id: Int) {
    getVisitNotes(notableId: $notable_id) {
      ...AdminNoteFields
    }
  }
`;

export default GET_VISIT_NOTES_QUERY;
