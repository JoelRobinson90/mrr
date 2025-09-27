import React from 'react';
import { useQuery } from '@apollo/client';
import { MockedProvider } from '@apollo/client/testing';

import PreviewScreen from '../../src/screens/preview/preview';

import {
  renderWithProviders, fireEvent, act, waitFor, cleanup,
} from '../../src/helpers/testingLibrary';

import GET_CURRENT_USER_QUERY from '../../src/graphql/queries/user/currentUser';
import CREATE_VISIT_EVENT_MUTATION from '../../src/graphql/mutations/visit_event/createVisitEvent';
import GET_VISIT_QUERY from '../../src/graphql/queries/visits/getVisit';

import useCheckValidAuth from '../../src/hooks/useCheckValidAuth';

const visit = {
  id: 1,
  status: 'en_route',
  visit_events: [],
  canceled: false,
  confirmed: true,
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
        event_type: 'on_site',
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
          status: 'en_route',
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

jest.mock('../../src/hooks/useCheckValidAuth');

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
    navigate: mockedNavigate,
  };

  beforeEach(() => {
    useCheckValidAuth.mockReturnValue();
    useQuery.mockReturnValue({
      data: { getCurrentUser, getVisit: { ...visit, status: 'on_site' } },
      refetch: mockedRefetch,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('render preview', async () => {
    const { getByText } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <PreviewScreen
          route={{ params: { visit, preview: false } }}
          navigation={{ ...navigation, setOptions: jest.fn() }}
        />
      </MockedProvider>,
    );

    expect(getByText('Start Navigation')).toBeDefined();
    expect(getByText('1330 Grand Ave')).toBeDefined();
    expect(getByText("I've Arrived")).toBeDefined();
  });

  it("navigates to SummaryScreen on I've Arrived button press", async () => {
    const { queryByTestId } = renderWithProviders(
      <MockedProvider mocks={mocks} addTypename={false}>
        <PreviewScreen
          route={{ params: { visit: { id: 1 }, preview: false } }}
          navigation={{ ...navigation, setOptions: jest.fn() }}
        />
      </MockedProvider>,
    );

    await act(async () => {
      fireEvent.press(queryByTestId('arrivedButton'));
      await waitFor(() => {
        expect(mockedRefetch).toHaveBeenCalled();
      });
    });

    await waitFor(() => {
      expect(mockedNavigate).toHaveBeenCalledWith('Summary', { visit: { ...visit, status: 'on_site' } });
    });
  });
});
