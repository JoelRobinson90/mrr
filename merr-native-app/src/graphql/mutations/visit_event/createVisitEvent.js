import { gql } from '@apollo/client';

const CREATE_VISIT_EVENT_MUTATION = gql`
  mutation CreateVisitEventMutation(
    $time: String!
    $location: String!
    $field_provider_id: Int!
    $visit_id: Int!
    $event_type: String!
  ) {
    createVisitEvent(
      input: {
        time: $time
        location: $location
        fieldProviderId: $field_provider_id
        visitId: $visit_id
        eventType: $event_type
      }
    ) {
      visitEvent {
        id
      }
      errors
    }
  }
`;

export default CREATE_VISIT_EVENT_MUTATION;
