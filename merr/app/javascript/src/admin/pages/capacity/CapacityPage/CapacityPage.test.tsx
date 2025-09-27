import React from 'react';
import { CapacityPage } from './CapacityPage';
import { screen, render, waitForElementToBeRemoved, act } from '@testing-library/react';
import moment from 'moment';

const now = moment();

const PATIENT_1 = {
  first_name: 'Marlon',
  last_name: 'Mantilla',
};

const PATIENT_2 = {
  first_name: 'Jane',
  last_name: 'Doe',
};

const PATIENT_3 = {
  first_name: 'Peter',
  last_name: 'Parker',
};

const FIRST_PROVIDER_NAME = 'Baylee Texas';
const HOUSTON_PROVIDER_NAME = 'Houston TX FP';
const BRIGHT_PROVIDER_NAME = 'Bright FP';

const GROUPS = {
  molina: 'Molina',
  bright: 'Bright Health',
};

const MOCKED_RESPONSE = {
  shifts: [
    {
      fp_id: '8055',
      start_time: now.clone().set('hour', 8).set('minute', 0),
      end_time: now.clone().set('hour', 23).set('minute', 0),
      fp_name: FIRST_PROVIDER_NAME,
      groups: [GROUPS.molina],
      location: '29.76018,-95.36935',
    },
    {
      fp_id: '45540',
      start_time: now.clone().set('hour', 8).set('minute', 0),
      end_time: now.clone().set('hour', 23).set('minute', 0),
      fp_name: HOUSTON_PROVIDER_NAME,
      groups: ['Molina'],
      location: '30.05011,-95.47703',
    },
    {
      fp_id: '12316',
      start_time: now.clone().set('hour', 8).set('minute', 0),
      end_time: now.clone().set('hour', 23).set('minute', 0),
      fp_name: BRIGHT_PROVIDER_NAME,
      groups: [GROUPS.bright],
      location: '35.20329,-80.86393',
    },
  ],
  visits: [
    {
      alayacare_visit_id: 1212,
      fp_id: '8055',
      location: '29.810283,-95.317813',
      start_time: now.clone().set('hour', 9).set('minute', 10),
      end_time: now.clone().set('hour', 9).set('minute', 30),
      demand_partner_id: null,
      patient: PATIENT_1,
      status: 'scheduled',
      client_id: 'AWODIU1BB3001',
      visit_type: null,
      drive_time: 8,
      drive_distance: 6.306933276995539,
      visit_id: 'TEST_0',
      id: 'TEST_0',
    },
    {
      alayacare_visit_id: 1216,
      fp_id: '8055',
      location: '29.803413,-95.325936',
      start_time: now.clone().set('hour', 10).set('minute', 10),
      end_time: now.clone().set('hour', 10).set('minute', 30),
      demand_partner_id: null,
      patient: PATIENT_2,
      status: 'scheduled',
      client_id: 'AWODIU1BB30011',
      visit_type: null,
      drive_time: 9,
      drive_distance: 5.610995811947755,
      visit_id: 'TEST_1',
      id: 'TEST_1',
    },
    {
      alayacare_visit_id: 1201,
      fp_id: '12316',
      location: '35.17088,-80.9825',
      start_time: now.clone().set('hour', 11).set('minute', 10),
      end_time: now.clone().set('hour', 11).set('minute', 30),
      demand_partner_id: null,
      patient: PATIENT_3,
      status: 'cancelled',
      client_id: '8388',
      visit_type: null,
      drive_time: 20,
      drive_distance: 8.724073222563288,
    },
    {
      alayacare_visit_id: 1212,
      fp_id: '8055',
      location: '29.810283,-95.317813',
      start_time: now.clone().add(1, 'day').set('hour', 9).set('minute', 10),
      end_time: now.clone().add(1, 'day').set('hour', 9).set('minute', 30),
      demand_partner_id: null,
      patient: PATIENT_1,
      status: 'scheduled',
      client_id: 'AWODIU1BB3001',
      visit_type: null,
      drive_time: 8,
      drive_distance: 6.306933276995539,
      visit_id: 'TEST_2',
      id: 'TEST_2',
    },
    {
      alayacare_visit_id: 1212,
      fp_id: '8055',
      location: '29.810283,-95.317813',
      start_time: now.clone().add(1, 'day').set('hour', 9).set('minute', 10),
      end_time: now.clone().add(1, 'day').set('hour', 9).set('minute', 30),
      demand_partner_id: null,
      patient: PATIENT_1,
      status: 'scheduled',
      client_id: 'AWODIU1BB3001',
      visit_type: null,
      drive_time: 8,
      drive_distance: 6.306933276995539,
      visit_id: 'TEST_3',
      id: 'TEST_3',
    },
  ],
  drive_times: [
    {
      alayacare_visit_id: 1212,
      start_time: now.clone().set('hour', 9).set('minute', 0),
      end_time: now.clone().set('hour', 9).set('minute', 10),
      fp_id: '8055',
      title: '8 min',
    },
    {
      alayacare_visit_id: 1216,
      start_time: now.clone().set('hour', 10).set('minute', 0),
      end_time: now.clone().set('hour', 10).set('minute', 10),
      fp_id: '8055',
      title: '9 min',
    },
    {
      alayacare_visit_id: 1201,
      start_time: now.clone().set('hour', 11).set('minute', 0),
      end_time: now.clone().set('hour', 11).set('minute', 10),
      fp_id: '12316',
      title: '20 min',
    },
  ],
};

describe('<CapacityPage />', () => {
  beforeEach(() => {
    const fetchMock = jest
      .fn()
      .mockReturnValue(
        Promise.resolve({
          status: 200,
          json: () => {
            return Promise.resolve(MOCKED_RESPONSE);
          },
        }),
      );

    window.fetch = fetchMock;
  });

  it('renders calendar with field providers and visits', async () => {
    render(<CapacityPage layout_props={{}} current_user={{}} />);

    expect(fetch).toBeCalledTimes(1);

    await act(async () => {
      expect(screen.getByText('Loading, please wait ...')).toBeVisible();
      await waitForElementToBeRemoved(() => screen.getByText('Loading, please wait ...'));
    });

    expect(screen.getByText(FIRST_PROVIDER_NAME)).toBeInTheDocument();
    expect(screen.getByText(BRIGHT_PROVIDER_NAME)).toBeInTheDocument();
    expect(screen.getByText(HOUSTON_PROVIDER_NAME)).toBeInTheDocument();

    // // check visits rendering
    expect(screen.getByText(`${PATIENT_1.first_name} ${PATIENT_1.last_name}`)).toBeInTheDocument();

    expect(screen.getByText(`${PATIENT_2.first_name} ${PATIENT_2.last_name}`)).toBeInTheDocument();

    expect(screen.getByText(`${PATIENT_3.first_name} ${PATIENT_3.last_name}`)).toBeInTheDocument();

    screen.getByText('Week').click();
  });

  it('switch to week view and render visits', async () => {
    render(<CapacityPage layout_props={{}} current_user={{}} />);

    expect(fetch).toBeCalledTimes(1);
    await act(async () => {
      expect(screen.getByText('Loading, please wait ...')).toBeVisible();
      await waitForElementToBeRemoved(() => screen.getByText('Loading, please wait ...'));
    });

    // Switch to Week view
    await act(async () => {
      screen.getByText('Week').click();
    });

    expect(screen.getAllByText(`${PATIENT_1.first_name} ${PATIENT_1.last_name}`)).toHaveLength(3);

    expect(screen.getByText(`${PATIENT_2.first_name} ${PATIENT_2.last_name}`)).toBeInTheDocument();

    expect(screen.getByText(`${PATIENT_3.first_name} ${PATIENT_3.last_name}`)).toBeInTheDocument();
  });
});