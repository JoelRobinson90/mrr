import React from 'react';
import { MockedProvider } from '@apollo/client/testing';
import * as Location from 'expo-location';

import VisitScreen from '../../../src/screens/visit/visit';

import {
  renderWithProviders, fireEvent, act, waitFor, cleanup,
} from '../../../src/helpers/testingLibrary';

import GET_CURRENT_USER_QUERY from '../../../src/graphql/queries/user/currentUser';
import CREATE_VISIT_EVENT_MUTATION from '../../../src/graphql/mutations/visit_event/createVisitEvent';
import GET_VISIT_QUERY from '../../../src/graphql/queries/visits/getVisit';

import useCheckValidAuth from '../../../src/hooks/useCheckValidAuth';
import useDeviceType from '../../../src/hooks/useDeviceType';

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

const getCurrentUser = {
  id: 1,
  email: 'john.smith@medarrive.com',
  displayName: 'John Smith',
  account: {
    id: 1,
    firstName: 'John',
    lastName: 'Smith',
  },
};

const mocks = [
  {
    request: {
      query: GET_CURRENT_USER_QUERY,
    },
    result: {
      data: {
        getCurrentUser,
      },
    },
  },
  {
    request: {
      query: CREATE_VISIT_EVENT_MUTATION,
      variables: {
        time: new Date(),
        location: '39.080852, -94.58582',
        field_provider_id: 1,
        visit_id: 1,
        event_type: 'en_route',
      },
    },
    result: {
      data: {
        visitEvent: {
          id: 1,
        },
      },
    },
  },
  {
    request: {
      query: GET_VISIT_QUERY,
      variables: {
        id: 1,
      },
    },
    result: {
      data: {
        getVisit: {
          ...visit,
          status: 'scheduled',
        },
      },
    },
  },
];

const mockedNavigate = jest.fn();
const mockedRefetch = jest.fn(async () => {
  const data = await Promise.resolve(jest.fn());
  return data;
});

jest.mock('../../../src/hooks/useCheckValidAuth');
jest.mock('../../../src/hooks/useDeviceType');

jest.mock('expo-location');
jest.mock('@apollo/client', () => {
  const originalModule = jest.requireActual('@apollo/client');
  return {
    __esModule: true,
    ...originalModule,
    useQuery: jest.fn().mockImplementation(() => ({
      data: { getCurrentUser },
      refetch: mockedRefetch,
    })),
    useMutation: jest.fn().mockImplementation(() => ([() => jest.fn(), { loading: false }])),
    HttpLink: jest.fn().mockImplementation(() => ({
      request: jest.fn(),
    })),
  };
});
jest.mock('@expo/vector-icons', () => ({
  Ionicons: 'Ionicons',
}));

describe('VisitScreen', () => {
  const navigation = {
    navigate: mockedNavigate,
  };

  beforeEach(() => {
    useCheckValidAuth.mockReturnValue();
    Location.getCurrentPositionAsync.mockReturnValueOnce(
      Promise.resolve({ coords: { latitude: '39.080852', longitude: '-94.58582' } }),
    );
    useDeviceType.mockReturnValue({ isMobile: true });
  });

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('renders visit with status Scheduled', async () => {
    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <VisitScreen
          route={{
            params: {
              visit: { ...visit, confirmed: false },
            },
          }}
          navigation={navigation}
        />
      </MockedProvider>,
    );

    expect(getByText('John Doe')).toBeDefined();
    expect(getByText('Visit #1')).toBeDefined();
    expect(getByText('Regression Visit Type')).toBeDefined();
    expect(getByText('John Smith')).toBeDefined();
    expect(getByText('Scheduled')).toBeDefined();
  });

  it('renders visit with status Confirmed', async () => {
    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <VisitScreen
          route={{ params: { visit: { ...visit, confirmed: true } } }}
          navigation={navigation}
        />
      </MockedProvider>,
    );

    expect(getByText('John Doe')).toBeDefined();
    expect(getByText('Visit #1')).toBeDefined();
    expect(getByText('Regression Visit Type')).toBeDefined();
    expect(getByText('John Smith')).toBeDefined();
    expect(getByText('Confirmed')).toBeDefined();
  });

  it('navigates to PreviewScreen on En Route button press', async () => {
    const { queryByTestId } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <VisitScreen route={{ params: { visit } }} navigation={navigation} />
      </MockedProvider>,
    );

    const enRouteButton = queryByTestId('enRouteButton');
    act(() => { fireEvent.press(enRouteButton); });

    expect(0).toBe(0);

    await waitFor(() => {
      expect(mockedNavigate).toHaveBeenCalledWith('Preview', { visit, preview: false });
    });
  });
});
