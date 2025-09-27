import React from 'react';
import {
  renderWithProviders, fireEvent, cleanup, act,
} from '../../src/helpers/testingLibrary';
import VisitCard from '../../src/components/VisitCard';

const mockedUsedNavigate = jest.fn();

jest.mock('@react-navigation/native', () => {
  const actualNav = jest.requireActual('@react-navigation/native');
  return {
    ...actualNav,
    useNavigation: () => ({
      navigate: mockedUsedNavigate,
    }),
  };
});

describe('VisitCard test suite', () => {
  const visit = {
    patient: {
      first_name: 'John',
      last_name: 'Doe',
      address: {
        city: 'Los Angeles',
        state: 'California',
        zipcode: '90012',
        address_line_one: '1234 Example Street',
        timezone: 'America/Los_Angeles',
      },
    },
    status: 'scheduled',
    start_time: '2022-02-22T18:00:00Z',
    visit_type: {
      name: 'Example visit type',
    },
    confirmed: true,
    cx_start: '2022-02-22T18:00:00Z',
    cx_end: '2022-02-22T19:00:00Z',
    providers: [],
  };

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('renders the visit card', () => {
    const { getByText } = renderWithProviders(
      <VisitCard visit={visit} setAndOpenModal={jest.fn()} actionsAllowed={() => jest.fn()} />,
    );

    expect(getByText('Los Angeles California, 90012')).not.toBeNull();
    expect(getByText('Example visit type')).not.toBeNull();
    expect(getByText('John D.')).not.toBeNull();
    expect(getByText('Preview Location')).not.toBeNull();
  });

  it('calls setAndOpenModal function when patient information is pressed', () => {
    const setAndOpenModal = jest.fn();
    const { getByText } = renderWithProviders(
      <VisitCard
        visit={visit}
        setAndOpenModal={setAndOpenModal}
        actionsAllowed={() => jest.fn()}
      />,
    );
    const patientInfo = getByText('John D.');
    act(() => {
      fireEvent.press(patientInfo);
    });
    expect(setAndOpenModal).toHaveBeenCalledWith(visit);
  });

  it('navigates to Visit screen when visit card is pressed', () => {
    const setAndOpenModal = jest.fn();
    const { queryByTestId } = renderWithProviders(
      <VisitCard
        visit={visit}
        setAndOpenModal={setAndOpenModal}
        actionsAllowed={jest.fn()}
      />,
    );

    const visitCard = queryByTestId('visitCard');
    act(() => {
      fireEvent.press(visitCard);
    });
    expect(mockedUsedNavigate).toHaveBeenCalledWith('Visit', { visit });
  });
});
