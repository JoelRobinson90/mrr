import React from 'react';
import { getPatientAge, PatientShowPageComponent } from './PatientShowPage';
import { screen, render } from '@testing-library/react';
import { AdminAppContext, AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';
import moment from 'moment';
import { FlashToast } from '@/common/components/FlashToast/FlashToast';
import { MockedProvider } from '@apollo/client/testing';

const now = moment();

const STATUSES = [
  'Care Complete',
  'Created',
  'Referred: Cancelled',
  'Referred: Needs Scheduling',
  'Scheduled with Issue',
  'Referred: Cancelled',
  'Referred: Scheduled',
];

const TestAdminProvider = ({ children }) => (
  <AdminAppContext.Provider
    value={{
      currentUser: {
        __typename: 'User',
        id: 'test-user-id',
        email: 'admin@medarrive.com',
        displayName: 'Admin User',
        account: {
          __typename: 'MedarriveAdmin',
          firstName: 'Admin',
          lastName: 'User',
        },
      },
    }}
  >
    <MockedProvider>
      <FlashToast>{children}</FlashToast>
    </MockedProvider>
  </AdminAppContext.Provider>
);

describe('<PatientShowPage />', () => {
  const patient = {
    id: 1,
    address: {
      timezone: 'America/Los_Angeles',

      city: 'LA',
      state: 'CA',
    },
    first_name: 'Ronna',
    last_name: 'Quitzon',
    gender: 'Male',
    date_of_birth: '1978-11-23',
    medical_record_number: '329247596',
    phone_number: '(354) 855-7775',
    location: 'North Shonnaview, NE',
    partner: 'partner-1',
    status: 'Needing Services',
    provider_org: {
      name: 'Millenium Physician Group',
    },
  };

  const mocked_visits = [
    {
      alayacare_visit_id: 1212,
      fp_id: '8055',
      location: '29.810283,-95.317813',
      start_time: now.clone().set('hour', 9).set('minute', 10),
      end_time: now.clone().set('hour', 9).set('minute', 30),
      demand_partner_id: null,
      patient: patient,
      status: 'missed',
      client_id: 'AWODIU1BB3001',
      visit_type: null,
      drive_time: 8,
      drive_distance: 6.306933276995539,
    },
    {
      alayacare_visit_id: 1216,
      fp_id: '8055',
      location: '29.803413,-95.325936',
      start_time: now.clone().set('hour', 10).set('minute', 10),
      end_time: now.clone().set('hour', 10).set('minute', 30),
      demand_partner_id: null,
      patient: patient,
      status: 'missed',
      client_id: 'AWODIU1BB30011',
      visit_type: null,
      drive_time: 9,
      drive_distance: 5.610995811947755,
    },
    {
      alayacare_visit_id: 1201,
      fp_id: '12316',
      location: '35.17088,-80.9825',
      start_time: now.clone().set('hour', 11).set('minute', 10),
      end_time: now.clone().set('hour', 11).set('minute', 30),
      demand_partner_id: null,
      patient: patient,
      status: 'missed',
      client_id: '8388',
      visit_type: null,
      drive_time: 20,
      drive_distance: 8.724073222563288,
    },
  ];

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

  it('renders without error', async () => {
    beforeEach(() => {
      const fetchMock = jest.fn().mockReturnValueOnce(
        Promise.resolve({
          status: 200,
          json: () => {
            return Promise.resolve(mocked_visits);
          },
        }),
      );

      window.fetch = fetchMock;
    });

    render(
      <TestAdminProvider>
        <PatientShowPageComponent patient={patient} layout_props={layoutProps} statuses={STATUSES} />
      </TestAdminProvider>,
    );

    // check for the breadcrumb & the page body content
    const items = await screen.getAllByText(`${patient.first_name} ${patient.last_name}`);

    items.forEach((item) => expect(item).toBeInTheDocument());
  });

  // it('shows appointment times in their respective timezones', () => {
  //   const appointmentTimes = [
  //     {
  //       id: randomId(),
  //       start_time: '2021-02-17T15:00:00.000Z',
  //       timezone: 'America/Los_Angeles',
  //     },
  //   ];

  //   const { getByText } = render(
  //     <PatientShowPage
  //       patient={patient}
  //       layout_props={layoutProps}
  //       statuses={STATUSES}
  //     />,
  //   );

  //   expect(getByText(/Wednesday, February 17th, 2021 7:00am PST/)).toBeInTheDocument();
  // });

  describe('content', () => {
    it('shows patient info', () => {
      const { getAllByText } = render(
        <TestAdminProvider>
          <PatientShowPageComponent patient={patient} layout_props={layoutProps} statuses={STATUSES} />
        </TestAdminProvider>,
      );
      expect(getAllByText('Ronna Quitzon')).toHaveLength(1);
    });
  });
});

describe('#getPatientAge', () => {
  beforeAll(() => {
    // lock time
    jest.useFakeTimers('modern');
    jest.setSystemTime(new Date(1612988168820));
  });

  afterAll(() => {
    // unlock time
    jest.useRealTimers();
  });

  describe('Given the date in the format: YYYY-MM-DD', () => {
    it('formats the date properly', () => {
      expect(getPatientAge('1978-11-23')).toEqual('42 years old');
      expect(getPatientAge('1938-02-06')).toEqual('83 years old');
      expect(getPatientAge('1927-11-24')).toEqual('93 years old');
    });
  });
});
