import { gql } from '@apollo/client';

const CANCEL_VISIT_MUTATION = gql`
  mutation CancelVisitMutation($id: ID!, $cancel_code_id: ID!, $note: String) {
    cancelVisit(input: {
      id: $id,
      cancelCodeId: $cancel_code_id,
      note: $note
    }) {
      visit {
        id
        adminNotes {
          id
          content
        }
      }
      errors
    }
  }
`;

export default CANCEL_VISIT_MUTATION;
