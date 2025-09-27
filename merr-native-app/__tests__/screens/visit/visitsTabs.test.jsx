import React from 'react';
import * as Linking from 'expo-linking';
import { useQuery } from '@apollo/client';
import { MockedProvider } from '@apollo/client/testing';
import { getCalendars } from 'expo-localization';

import VisitsTabs from '../../../src/screens/visit/visitsTabs';

import { renderWithProviders, fireEvent, act } from '../../../src/helpers/testingLibrary';

import GET_VISIT_QUERY from '../../../src/graphql/queries/visits/getVisit';

import useGeolocation from '../../../src/hooks/useGeolocation';
import useCheckValidAuth from '../../../src/hooks/useCheckValidAuth';

const visit = {
  id: 1,
  status: 'scheduled',
  visit_events: [],
  canceled: false,
  confirmed: false,
  external_id: 'Visit_eMUidFgFfiqpffLc',
  patient: {
    first_name: 'John',
    last_name: 'Doe',
    display_name: 'John Doe',
    date_of_birth: '1985-04-20',
    address: {
      address_line_one: '1330 Grand Ave',
      address_line_two: null,
      city: 'Des Moines',
      county: null,
      created_at: '2023-03-24T22:07:38Z',
      id: '28',
      latitude: '41.5853675',
      longitude: '-93.63476329999999',
      notes: null,
      state: 'IA',
      timezone: 'America/Los_Angeles',
      zipcode: '50309',
    },
    medical_record_number: 'Reg-patient-01',
    phone_number: '+17345467319',
    programs: [
      {
        id: '3',
        name: 'Regression Program',
      },
      {
        id: '1',
        name: 'Default program',
      },
    ],
  },
  program: {
    id: 3,
    name: 'Regression Program',
    v2: true,
  },
  start_time: new Date().toISOString(),
  end_time: new Date().toISOString(),
  cx_start: new Date().toISOString(),
  cx_end: new Date().toISOString(),
  visit_type: {
    duration: 30,
    id: 2,
    name: 'Regression Visit Type',
  },
  services: [
    {
      id: 62,
      name: 'Regression Service Vaccine',
    },
    {
      id: 9,
      name: 'Regression Service Covid',
    },
  ],
  field_provider: {
    first_name: 'John',
    id: 1,
    last_name: 'Smith',
  },
  providers: [
    {
      id: 1,
      first_name: 'John',
      last_name: 'Smith',
      role: 'field_provider',
    },
  ],
};

const mockVisitClean = [
  {
    request: {
      query: GET_VISIT_QUERY,
      variables: {
        limit: 20,
        start_time: new Date().toISOString(),
        end_time: new Date().toISOString(),
      },
    },
    result: {
      data: {
        getVisit: [],
      },
    },
  },
];

const mockVisit = [
  {
    request: {
      query: GET_VISIT_QUERY,
      variables: {
        limit: 20,
        start_time: new Date().toISOString(),
        end_time: new Date().toISOString(),
      },
    },
    result: {
      data: {
        getVisits: [visit],
      },
    },
  },
];

const mockRequestPermissions = jest.fn();

// eslint-disable-next-line react/prop-types
jest.mock('../../../src/components/FullScreenLoading.jsx', () => function FullScreenLoadingMock({ children }) {
  return <div>{children}</div>;
});

jest.mock('../../../src/hooks/useCheckValidAuth');

jest.mock('../../../src/hooks/useGeolocation', () => ({
  __esModule: true,
  default: jest.fn(),
}));

const mockedRefetch = jest.fn(async () => {
  const data = await Promise.resolve(jest.fn());
  return data;
});

jest.mock('expo-linking');
jest.mock('expo-localization');
jest.mock('@apollo/client', () => {
  const originalModule = jest.requireActual('@apollo/client');
  return {
    __esModule: true,
    ...originalModule,
    useQuery: jest.fn(),
  };
});

describe('VisitsTabs', () => {
  beforeEach(() => {
    Linking.openSettings.mockImplementationOnce(() => Promise.resolve());
    useCheckValidAuth.mockReturnValue();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should render geolocation without permissions and Request Permissions Button', () => {
    useGeolocation.mockReturnValue({
      requestPermissions: mockRequestPermissions,
      permissionDenied: false,
      isLocationGranted: false,
    });

    const { getByText, queryByTestId } = renderWithProviders(<VisitsTabs />);

    act(() => fireEvent.press(queryByTestId('buttonRequestPermissions')));

    expect(getByText('We need your location data')).toBeDefined();
    expect(getByText('We need your location for safety reasons to ensure we know the location of our field providers while they are in the field and in patient homes.')).toBeDefined();
    expect(getByText('Request Permissions')).toBeDefined();
    expect(mockRequestPermissions).toHaveBeenCalled();
  });

  it('should render geolocation without permissions and Open Phone Settings Button', async () => {
    useGeolocation.mockReturnValue({
      requestPermissions: mockRequestPermissions,
      permissionDenied: true,
      isLocationGranted: false,
    });

    const { getByText, queryByTestId } = renderWithProviders(<VisitsTabs />);

    expect(getByText('We need your location data')).toBeDefined();
    expect(getByText('We need your location for safety reasons to ensure we know the location of our field providers while they are in the field and in patient homes.')).toBeDefined();
    expect(getByText('Open Phone Settings')).toBeDefined();

    await act(() => fireEvent.press(queryByTestId('buttonOpenPhoneSettings')));
    expect(Linking.openSettings).toHaveBeenCalled();
  });

  it('should render Modal', async () => {
    useGeolocation.mockReturnValue({
      requestPermissions: mockRequestPermissions,
      permissionDenied: true,
      isLocationGranted: false,
    });

    const { getByText, queryByTestId } = renderWithProviders(<VisitsTabs />);

    await act(() => fireEvent.press(queryByTestId('buttonOpenPhoneSettings')));

    expect(getByText('Location Permissions')).toBeDefined();
    expect(getByText('In order to use this application, it is necessary to know your location.')).toBeDefined();
    expect(getByText('Continue')).toBeDefined();
  });

  it('should close Modal', async () => {
    useGeolocation.mockReturnValue({
      requestPermissions: mockRequestPermissions,
      permissionDenied: true,
      isLocationGranted: false,
    });

    const { queryByText, queryByTestId } = renderWithProviders(<VisitsTabs />);

    await act(() => fireEvent.press(queryByTestId('buttonOpenPhoneSettings')));
    act(() => fireEvent.press(queryByText('Continue')));

    expect(queryByText('We need your location data')).toBeDefined();
  });

  it('should VisitList without visits', async () => {
    useGeolocation.mockReturnValue({ isLocationGranted: true });
    useQuery.mockReturnValue({
      data: { getVisit: [] },
      refetch: mockedRefetch,
      startPolling: jest.fn(),
      stopPolling: jest.fn(),
    });

    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mockVisitClean} addTypename={false}>
        <VisitsTabs />
      </MockedProvider>,
    );

    await act(() => {
      expect(getByText('Visits List')).toBeDefined();
      expect(getByText('Upcoming')).toBeDefined();
      expect(getByText('Past')).toBeDefined();
      expect(getByText('No visits scheduled')).toBeDefined();
    });
  });

  it('should VisitList with visits', async () => {
    useGeolocation.mockReturnValue({ isLocationGranted: true });
    getCalendars.mockReturnValue('America/Los_Angeles');
    useQuery.mockReturnValue({
      data: { getVisits: [visit] },
      refetch: mockedRefetch,
      startPolling: jest.fn(),
      stopPolling: jest.fn(),
    });

    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mockVisit} addTypename={false}>
        <VisitsTabs />
      </MockedProvider>,
    );

    await act(() => {
      expect(getByText('Visits List')).toBeDefined();
      expect(getByText('Upcoming')).toBeDefined();
      expect(getByText('Past')).toBeDefined();
      expect(getByText('Preview Location')).toBeDefined();
      expect(getByText('Scheduled')).toBeDefined();
    });
  });
});
