import React from 'react';

import { renderWithProviders, fireEvent, cleanup } from '../../src/helpers/testingLibrary';
import PatientModal from '../../src/components/PatientModal';
import useDeviceType from '../../src/hooks/useDeviceType';

jest.mock('../../src/hooks/useDeviceType');

describe('PatientModal test suite', () => {
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
      phone_number: '1234567890',
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

  beforeEach(() => {
    useDeviceType.mockReturnValue({ isMobile: true });
  });

  afterEach(() => {
    jest.clearAllMocks();
    cleanup();
  });

  it('renders the modal when modalVisible is true', () => {
    const { getByText } = renderWithProviders(
      <PatientModal
        modalVisible
        visit={visit}
        setModalVisible={jest.fn()}
        actionsAllowed
      />,
    );
    expect(getByText('John Doe')).not.toBeNull();
    expect(getByText('1234 Example Street')).not.toBeNull();
    expect(getByText('1234567890')).not.toBeNull();
  });

  it('calls external phone number when call button is pressed', () => {
    const openExternalUrlMock = jest.fn();
    const { queryByTestId } = renderWithProviders(
      <PatientModal
        modalVisible
        visit={visit}
        setModalVisible={jest.fn()}
        openExternalUrl={openExternalUrlMock}
      />,
    );

    const callButton = queryByTestId('callButton');
    fireEvent.press(callButton);
    expect('tel://1234567890').toBeTruthy();
  });
});
