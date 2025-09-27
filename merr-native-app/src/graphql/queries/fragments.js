import { gql } from '@apollo/client';

const PATIENT_FRAGMENT = gql`
  fragment PatientFields on Patient {
    id
    first_name: firstName
    last_name: lastName
    display_name: displayName
    medical_record_number: medicalRecordNumber
    date_of_birth: dateOfBirth
    phone_number: phoneNumber
    sex: sex
    preferred_language: preferredLanguage
    contact_email: contactEmail
    demandPartner {
      id
      name
    }
    programs {
      id
      name
    }
    address {
      id
      address_line_one: addressLineOne
      address_line_two: addressLineTwo
      city
      state
      zipcode
      created_at: createdAt
      latitude
      longitude
      notes
      timezone
      county
    }
  }
`;

const NOTE_FRAGMENT = gql`
  fragment AdminNoteFields on AdminNote {
    id
    creator: creator {
      display_name: displayName
    }
    content: content
    created_at: createdAt
    notable_id: notableId
  }
`;

const VISIT_FIELDS_FRAGMENT = gql`
  ${PATIENT_FRAGMENT}
  ${NOTE_FRAGMENT}
  fragment VisitFields on Visit {
    id
    start_time: startTime
    cx_start: cxStart
    cx_end: cxEnd
    arrival_window_start: arrivalWindowStart
    arrival_window_end: arrivalWindowEnd
    end_time: endTime
    service_instructions: serviceInstructions
    canceled
    confirmed
    external_id: externalId
    alayacare_status: alayacareStatus
    status: displayStatus
    athenaTelehealthUrl
    visit_events: visitEvents {
      id
      time
      event_type: eventType
      location
      field_provider: fieldProvider {
        id
      }
    }
    field_provider: fieldProvider {
      id
      first_name: firstName
      last_name: lastName
    }
    admin_notes: adminNotes {
      ...AdminNoteFields
    }
    visit_type: visitType {
      id
      duration
      name
    }
    program {
      id
      name
      v2
    }
    services {
      id
      name
      duration
    }
    patient {
      ...PatientFields
    }
    providers {
      id
      first_name: firstName
      last_name: lastName
      role
    }
    visitGroup {
      id
      visits {
        id
      }
    }
  }
`;

export { PATIENT_FRAGMENT, VISIT_FIELDS_FRAGMENT, NOTE_FRAGMENT };
