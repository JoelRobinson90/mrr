import React from 'react';
import { ScheduleVisitPage } from './ScheduleVisitPage';
import { screen, render, act } from '@testing-library/react';
import { AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MockedProvider } from '@apollo/client/testing';
import { GetSchedulerDataDocument, GetSchedulerDataQuery } from '@/generated/graphql';
import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';

const mockData: GetSchedulerDataQuery = {
  getSchedulerData: {
    suggestedVisits: [
      {
        fp_id: 'FieldProvider_NKVMBzw5FQuHzhc5',
        fp_name: 'Dallas FP',
        start_time: '2022-11-24 15:01:00 UTC',
        end_time: '2022-11-24 15:46:00 UTC',
        cx_start: '2022-11-24 15:00:00 UTC',
        cx_end: '2022-11-24 15:45:00 UTC',
        expected_drive: 0,
        run_id: 'b69fb41a-1c2c-4284-b715-2066b5d52b94',
        total_score: 99,
        drive_score: 100,
        proximity_score: 99,
        utilization_score: 95,
        shift_shortening_penalty_score: 100,
        rank_category: 'high',
        grace_period: 0,
        arrival_window_start: '2022-11-24 14:40:00 UTC',
        arrival_window_end: '2022-11-24 15:20:00 UTC',
        resources: [],
        __typename: 'SchedulerVisit',
      },
      {
        fp_id: 'FieldProvider_NKVMBzw5FQuHzhc5',
        fp_name: 'Dallas FP',
        start_time: '2022-11-24 16:46:00 UTC',
        end_time: '2022-11-24 17:31:00 UTC',
        cx_start: '2022-11-24 16:45:00 UTC',
        cx_end: '2022-11-24 17:30:00 UTC',
        expected_drive: 0,
        run_id: 'b69fb41a-1c2c-4284-b715-2066b5d52b94',
        total_score: 99,
        drive_score: 100,
        proximity_score: 99,
        utilization_score: 95,
        shift_shortening_penalty_score: 100,
        rank_category: 'high',
        grace_period: 0,
        arrival_window_start: '2022-11-24 16:25:00 UTC',
        arrival_window_end: '2022-11-24 17:05:00 UTC',
        resources: [],
        __typename: 'SchedulerVisit',
      },
    ],
    success: true,
    errorMessage: null,
    __typename: 'SchedulerData',
  },
  getPatient: {
    id: '59',
    first_name: 'Kristopher',
    last_name: 'Mastick',
    medical_record_number: 'UU0922219882',
    address: {
      address_line_one: '11666 91st Pl NE',
      address_line_two: '',
      city: 'HOUSTON',
      state: 'TX',
      zipcode: '77090',
      created_at: '2022-08-15T17:36:07Z',
      updated_at: '2022-11-23T14:42:24Z',
      latitude: '30.0118752',
      longitude: '-95.4463322',
      notes: 'test',
      timezone: 'America/Chicago',
      addressable_type: 'Patient',
      addressable_id: 59,
      county: 'HARRIS',
      __typename: 'Address',
    },
    programs: [
      {
        id: '2',
        name: 'Texas',
        alayacare_service_code_id: '8',
        created_at: '2022-09-26T19:38:13Z',
        demand_partner_id: 5,
        udpated_at: '2022-09-26T20:14:31Z',
        demand_partner: {
          id: '5',
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
        ],
        visit_types: [
          {
            id: '9',
            name: 'Molina Initial Visit',
            alayacare_id: '9',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
        ],
        __typename: 'Program',
      },
      {
        id: '4',
        name: 'ED Utilization Reduction',
        alayacare_service_code_id: '8',
        created_at: '2022-10-06T17:42:14Z',
        demand_partner_id: 5,
        udpated_at: '2022-10-06T17:42:14Z',
        demand_partner: {
          id: '5',
          name: 'Molina',
          created_at: '2022-08-15T16:20:08Z',
          updated_at: '2022-08-15T16:30:47Z',
          __typename: 'DemandPartner',
        },
        services: [],
        visit_types: [],
        __typename: 'Program',
      },
      {
        id: '3',
        name: 'Another program',
        alayacare_service_code_id: '8',
        created_at: '2022-09-26T20:06:25Z',
        demand_partner_id: 5,
        udpated_at: '2022-09-26T20:06:25Z',
        demand_partner: {
          id: '5',
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
        ],
        visit_types: [
          {
            id: '1',
            name: 'Superior Initial Visit',
            alayacare_id: '17',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '2',
            name: 'A Test Service',
            alayacare_id: '16',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '3',
            name: 'Optum Serve Vaccine',
            alayacare_id: '15',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '4',
            name: 'Molina Phone Consultation',
            alayacare_id: '14',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '5',
            name: 'Centene - Health Net Vaccine',
            alayacare_id: '13',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '6',
            name: 'SCAN Flu and Vaccine',
            alayacare_id: '12',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '7',
            name: 'FCC',
            alayacare_id: '11',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '8',
            name: 'History and Physical',
            alayacare_id: '10',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '9',
            name: 'Molina Initial Visit',
            alayacare_id: '9',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '10',
            name: 'Molina Follow-up Visit',
            alayacare_id: '8',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '11',
            name: 'Molina Door to Door',
            alayacare_id: '7',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '12',
            name: 'Bright Healthcare History and Physical',
            alayacare_id: '6',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '13',
            name: 'Vault - Phlebotomy',
            alayacare_id: '5',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '14',
            name: 'Congestive Heart Failure',
            alayacare_id: '4',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '15',
            name: 'Post-Hospitalization Visit',
            alayacare_id: '3',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
          {
            id: '16',
            name: 'Example Service',
            alayacare_id: '1',
            services: [],
            duration: 0,
            requirements: [],
            __typename: 'VisitType',
          },
        ],
        __typename: 'Program',
      },
    ],
    serviceRequests: [
      {
        id: '1',
        programId: '1',
        serviceId: '1',
      },
    ],
    __typename: 'Patient',
  },
};

let mockError;

const mocks = [
  {
    request: {
      query: GetSchedulerDataDocument,
      variables: {
        patient_id: 59,
        program_id: '2',
        service_code_id: '11',
        top_suggestions: '',
        start_date: '2022-11-23',
        end_date: '2023-01-18',
        duration: '45',
        existing_visit_alayacare_id: 'undefined',
        external_id: 'undefined',
        limit_arrival_times: 'undefined',
        ignore_existing_visit_conflicts: false,
      },
    },
    result: {
      data: mockData,
      error: mockError,
    },
  },
];

describe('<ScheduleVisitPage />', () => {
  it('renders without error', async () => {
    const patient = {
      id: 1,
      first_name: 'Ronna',
      last_name: 'Quitzon',
      gender: 'Male',
      date_of_birth: '1978-11-23',
      medical_record_number: '329247596',
      phone_number: '(354) 855-7775',
      phone_number_type: 'Home',
      display_phone_number: '(354) 855-7775',
      location: 'North Shonnaview, NE',
      partner: 'partner-1',
      status: 'Needing Services',
      provider_org: {
        name: 'Millenium Physician Group',
      },
      custom_field_responses: [],
    };

    const layoutProps: AdminLayoutProps = {
      breadcrumbs: [
        {
          text: 'Patients',
          href: '#',
        },
        {
          text: `${patient.first_name} ${patient.last_name}`,
          href: '#',
        },
      ],
    };

    const { container } = render(
      <ApplicationLayout>
        <MockedProvider mocks={mocks} addTypename={false}>
          <ScheduleVisitPage patient_id="59" layout_props={layoutProps} />
        </MockedProvider>
      </ApplicationLayout>,
    );

    const items = await screen.getAllByText(`${patient.first_name} ${patient.last_name}`);

    items.forEach((item) => expect(item).toBeInTheDocument());
    // @TODO: add more tests after finishing UI design
  });
});

// @TODO: test validations
