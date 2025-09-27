import React from 'react';
import { useQuery } from '@apollo/client';
import { MockedProvider } from '@apollo/client/testing';

import VisitSummaryScreen from '../../../src/screens/visit/visitSummary';

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
  status: 'on_site',
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
        event_type: 'clocked_in',
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
      onCompleted: (e) => e,
    },
    result: {
      data: {
        getVisit: visit,
      },
    },
    onCompleted: (e) => e,
  },
];

const mocksComplete = [
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
        event_type: 'completed',
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
      onCompleted: (e) => e,
    },
    result: {
      data: {
        getVisit: { ...visit, status: 'clocked_in' },
      },
    },
    onCompleted: (e) => e,
  },
];

const mockedRefetch = jest.fn(async () => {
  const data = await Promise.resolve(jest.fn());
  return data;
});

jest.mock('../../../src/hooks/useCheckValidAuth');
jest.mock('../../../src/hooks/useDeviceType');

jest.mock('@apollo/client', () => {
  const originalModule = jest.requireActual('@apollo/client');
  return {
    __esModule: true,
    ...originalModule,
    useQuery: jest.fn(),
    useMutation: jest.fn().mockImplementation(() => ([() => jest.fn(), { loading: false }])),
    HttpLink: jest.fn().mockImplementation(() => ({
      request: jest.fn(),
    })),
    // onCompleted: jest.fn().mockImplementation(() => ({ getVisit: jest.fn() })),
  };
});

jest.mock('expo-location', () => {
  const original = jest.requireActual('expo-location');
  return {
    ...original,
    getForegroundPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted', canAskAgain: true }),
  };
});

describe('VisitScreen', () => {
  const navigation = {
    navigate: jest.fn(),
  };

  beforeEach(() => {
    // jest.spyOn(useQuery, 'onCompleted').mockImplementation(() => ({ getVisit: visit }));
    useCheckValidAuth.mockReturnValue();
    useDeviceType.mockReturnValue({ isMobile: true });
    useQuery.mockReturnValue({
      loading: false,
      error: null,
      data: { getCurrentUser, getVisit: visit },
      refetch: mockedRefetch,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('render summary', async () => {
    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <VisitSummaryScreen
          route={{ params: { visit: { id: 1 } } }}
          navigation={navigation}
        />
      </MockedProvider>,
    );

    expect(getByText('Visit # 1')).toBeDefined();
    expect(getByText('Regression Visit Type')).toBeDefined();
    expect(getByText('On Site')).toBeDefined();
    expect(getByText('Start Visit')).toBeDefined();
    expect(getByText('Phone Number: +17345467319')).toBeDefined();
  });

  it('should Start Visit button', async () => {
    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <VisitSummaryScreen
          route={{ params: { visit: { id: 1 } } }}
          navigation={navigation}
        />
      </MockedProvider>,
    );

    fireEvent.press(getByText('Start Visit'));

    useQuery.mockReturnValue({
      loading: false,
      error: null,
      data: {
        getCurrentUser,
        getVisit: {
          ...visit,
          status: 'clocked',
          visit_events: [{ event_type: 'clocked_in', time: new Date().toISOString() }],
        },
      },
      refetch: mockedRefetch,
    });

    await act(() => {
      expect(mockedRefetch).toHaveBeenCalled();
    });

    expect(getByText('Visit # 1')).toBeDefined();
    expect(getByText('Regression Visit Type')).toBeDefined();
    expect(getByText('Phone Number: +17345467319')).toBeDefined();

    await waitFor(() => {
      expect(getByText('In Progress')).toBeDefined();
      expect(getByText('Finish Visit')).toBeDefined();
    });
  });

  it('should Finish Visit button', async () => {
    useQuery.mockReturnValue({
      loading: false,
      error: null,
      data: {
        getCurrentUser,
        getVisit: {
          ...visit,
          status: 'clocked_in',
          visit_events: [{ event_type: 'clocked_in', time: new Date().toISOString() }],
        },
      },
      refetch: mockedRefetch,
    });

    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocksComplete} addTypename={false}>
        <VisitSummaryScreen
          route={{ params: { visit: { id: 1 } } }}
          navigation={navigation}
        />
      </MockedProvider>,
    );

    fireEvent.press(getByText('Finish Visit'));

    useQuery.mockReturnValue({
      loading: false,
      error: null,
      data: {
        getCurrentUser,
        getVisit: {
          ...visit,
          status: 'completed',
          visit_events: [{ event_type: 'completed', time: new Date().toISOString() }],
        },
      },
      refetch: mockedRefetch,
    });

    await act(() => {
      expect(mockedRefetch).toHaveBeenCalled();
    });

    expect(getByText('Visit # 1')).toBeDefined();
    expect(getByText('Regression Visit Type')).toBeDefined();
    expect(getByText('Phone Number: +17345467319')).toBeDefined();

    waitFor(() => {
      expect(getByText('Completed')).toBeDefined();
    });
  });
});
