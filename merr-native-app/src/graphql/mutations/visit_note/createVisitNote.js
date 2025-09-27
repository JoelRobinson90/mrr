import { gql } from '@apollo/client';

const CREATE_VISIT_NOTE_MUTATION = gql`
  mutation CreateVisitNoteMutation(
    $content: String!
    $current_user_id: Int!
    $visit_id: Int!
  ) {
    createVisitNote(
      input: {
        visitNoteParams: {
          currentUserId: $current_user_id
          visitId: $visit_id
          content: $content
        }
      }
    ) {
      visitNote {
        id
      }
      errors
    }
  }
`;

export default CREATE_VISIT_NOTE_MUTATION;
