/* eslint-disable @typescript-eslint/no-empty-function */
import React from 'react';
import { screen, render } from '@testing-library/react';
import { SuggestedVisit } from '@/common/types';
import { VisitSidePanel } from './VisitSidePanel';
import { act } from 'react-dom/test-utils';
import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';

const patient = {
  id: 3,
  status: 'Created',
  date_of_birth: '1949-01-13',
  emergency_contact_name: 'Titus Considine CPA',
  first_name: 'Jon',
  middle_initial: 'J',
  last_name: 'Doe',
  medical_record_number: 'AAAAAAAA',
  phone_number: '+2055551234',
  phone_number_type: '',
  display_phone_number: '(205) 555-1234',
  display_secondary_phone_number: '(205) 555-1234',
  preferred_pronouns: null,
  secondary_phone_number: '(205) 555-1234',
  secondary_phone_number_type: '',
  consent_to_text: false,
  sex: 'Male',
  preferred_language: null,
  race: null,
  ethnicity: null,
  needs_hra_survey: null,
  race_summary: null,
  gender: null,
  ethnicity_summary: null,
  tags: [],
  primary_risk_category: '',
  address: {
    id: 4,
    address_line_one: 'EverGreen Ave 123',
    address_line_two: 'Apt 111',
    city: 'HOUSTON',
    latitude: '29.795327',
    longitude: '-95.58039459999999',
    notes: 'Omnis officiis mollitia. Et recusandae et. Similique nam commodi.',
    state: 'TX',
    zipcode: '77043',
    display_name: 'EverGreen Ave 123 Apt 1111, HOUSTON TX, 77043',
    county: '',
    timezone: 'America/Chicago',
  },
  custom_field_responses: [],
  user: {
    id: 7,
    email: 'jon.doe@medarrive.com',
    account_type: 'Patient',
    created_at: '2022-03-14T21:58:48.019Z',
    display_role: 'Patient',
    organization: {
      id: 1,
      name: 'Molina',
      created_at: '2022-03-14T21:58:34.203Z',
      updated_at: '2022-03-22T14:58:00.103Z',
      alayacare_id: 1030,
    },
    display_name: 'Jon Doe',
  },
};

const currentProgram = {
  id: '2',
  name: 'Molina',
  alayacare_service_code_id: '8',
  created_at: '2022-09-26T19:38:13Z',
  demand_partner_id: 5,
  udpated_at: '2022-09-26T20:14:31Z',
  demand_partner: {
    id: 5,
    name: 'Molina',
    created_at: '2022-08-15T16:20:08Z',
    updated_at: '2022-08-15T16:30:47Z',
    __typename: 'DemandPartner',
  },
  services: [
    {
      id: '1',
      name: 'Molina Visit Form (v071822)',
      duration: 0,
      alayacare_id: '295',
      __typename: 'Service',
    },
    {
      id: '6',
      name: 'Molina Visit Review (v060222)',
      duration: 0,
      alayacare_id: '272',
      __typename: 'Service',
    },
    {
      id: '9',
      name: 'Molina Visit Form (abridged, v060222)',
      duration: 0,
      alayacare_id: '266',
      __typename: 'Service',
    },
  ],
  visit_types: [
    {
      id: '9',
      name: 'Molina Initial Visit',
      alayacare_id: '9',
      services: [],
      __typename: 'VisitType',
    },
    {
      id: '10',
      name: 'Molina Follow-up Visit',
      alayacare_id: '8',
      services: [],
      __typename: 'VisitType',
    },
    {
      id: '11',
      name: 'Molina Door to Door',
      alayacare_id: '7',
      services: [],
      __typename: 'VisitType',
    },
  ],
  __typename: 'Program',
};

const currentVisitType = {
  id: 10,
  name: 'Molina Door to Door',
  duration: 30,
  alayacare_id: '7',
  program_id: 1,
  created_at: '2022-03-22T14:58:08.154Z',
  updated_at: '2022-03-22T14:58:08.154Z',
  services: [],
};

const currentServices = [
  {
    id: '10',
    name: 'Molina Visit Form (v031522)',
    alayacare_id: '231',
    created_at: '2022-03-22T14:58:20.674Z',
    updated_at: '2022-03-22T14:58:20.674Z',
    duration: 0,
  },
  {
    id: '21',
    name: 'Scheduling Follow Up Visits',
    alayacare_id: '188',
    created_at: '2022-03-22T14:58:20.979Z',
    updated_at: '2022-03-22T14:58:20.979Z',
    duration: 0,
  },
];

describe('<CreateVisitModal />', () => {
  describe('visit is selected', () => {
    const selectedVisit: SuggestedVisit = {
      fp_id: '8055',
      fp_name: 'Baylee Texas',
      start_time: '2022-06-17T14:19:00.000Z',
      end_time: '2022-06-17T14:49:00.000Z',
      cx_start: '2022-06-17T14:15:00.000Z',
      cx_end: '2022-06-17T14:45:00.000Z',
      expected_drive: 19,
      run_id: 'b5c3f683-df51-45db-bcf2-ac7a9cd812bb',
      total_score: 79,
      drive_score: 84,
      proximity_score: 59,
      utilization_score: 63,
      rank_category: 'high',
      id: 1,
      rank: 5,
      destination: '15',
      destination_drive_time: 30,
      origin: '15',
      origin_drive_time: 30,
      resources: [
        {
          resource_id: '8055',
          start_time: '2022-06-17T14:19:00.000Z',
          end_time: '2022-06-17T14:49:00.000Z',
          in_home: true,
        },
      ],
    };
    it('should display visit details', async () => {
      render(
        <ApplicationLayout>
          <VisitSidePanel
            program={currentProgram}
            services={currentServices}
            visitType={currentVisitType}
            setIsEditModalOpen={() => {}}
            duration="30"
            patient={patient}
            selectedVisit={selectedVisit}
            timezone={'America/Chicago'}
            onSubmit={() => {}}
            disableSubmit={false}
            onBackButton={() => {}}
            isScheduled={false}
            onRescheduleVisit={() => {
              console.log('reschedule visit.');
            }}
          />
        </ApplicationLayout>,
      );

      expect(screen.getByText('79%')).toBeVisible();
    });
  });
  describe('when no visit is selected', () => {
    it('should display program, visit type, services and duration', async () => {
      render(
        <ApplicationLayout>
          <VisitSidePanel
            program={currentProgram}
            services={currentServices}
            visitType={currentVisitType}
            setIsEditModalOpen={() => {}}
            duration="30"
            patient={patient}
            selectedVisit={null}
            timezone={'America/Chicago'}
            onSubmit={() => {}}
            disableSubmit={false}
            onBackButton={() => {}}
            isScheduled={false}
            onRescheduleVisit={() => {
              console.log('reschedule visit.');
            }}
          />
        </ApplicationLayout>,
      );
      act(() => {
        expect(screen.getByText('Add Visit')).toBeVisible();
        expect(screen.getByText('Jon Doe')).toBeVisible();
        expect(screen.getByText('30m')).toBeVisible();
        expect(screen.getByText('Molina')).toBeVisible();
        expect(screen.getByText('Molina Visit Form (v031522)')).toBeVisible();
        expect(screen.getByText('Scheduling Follow Up Visits')).toBeVisible();
      });
    });
  });
});
