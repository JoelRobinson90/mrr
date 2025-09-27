import React from 'react';
import { screen, render, fireEvent, within } from '@testing-library/react';
import { CreateVisitModal } from './CreateVisitModal';
import { Program } from '@/common/types';

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

describe('<CreateVisitModal />', () => {
  describe('when patient has 1 program with multiple visit types', () => {
    const programs: Program[] = [
      {
        id: '1',
        name: 'Molina',
        active: true,
        services: [
          {
            id: '3',
            name: 'Molina: Telehealth ESCALATION Only',
            duration: '15',
          },
        ],
        visit_types: [
          {
            id: 9,
            name: 'Molina Follow-up Visit',
            alayacare_id: '8',
            duration: 15,
            services: [
              {
                id: '10',
                name: 'Molina Visit Form (v031522)',
                duration: '40',
              },
            ],
          },
          {
            id: 10,
            name: 'Molina Door to Door',
            alayacare_id: '7',
            duration: 30,
            services: [
              {
                id: '10',
                name: 'Molina Visit Form (v031522)',
                duration: '40',
              },
            ],
          },
        ],
      },
    ];
    it('it preselect program and disables dropdown', async () => {
      render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning={true} />,
      );
      expect(screen.getByText('Add Visit')).toBeVisible();
      expect(
        screen.getByText(
          'Editing this information will present new results for the visit and this action cannot be undone',
        ),
      ).toBeVisible();

      const programDropdown = screen.getByTestId('program_id');

      expect(within(programDropdown).getByText('Molina')).toBeVisible();
      expect(within(programDropdown).getByRole('combobox')).toHaveClass('euiComboBox-isDisabled');
    });

    it('it shows dropdown for selecting visit types', async () => {
      const { getByText } = render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning />,
      );

      const visitDropdown = screen.getByTestId('visit_type_id');
      expect(within(visitDropdown).getByText('Please select a visit type the list')).toBeVisible();
      fireEvent.click(getByText('Please select a visit type the list'));
      const opt = screen.getByText('Molina Follow-up Visit');

      fireEvent.click(opt);
      expect(within(visitDropdown).getByText('Molina Follow-up Visit')).toBeVisible();
      expect(within(screen.getByTestId('services-group')).getByText('Molina Visit Form (v031522)')).toBeVisible();
    });

    it('it shows visit type duration by default', async () => {
      const { getByText } = render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning />,
      );

      const visitDropdown = screen.getByTestId('visit_type_id');
      expect(within(visitDropdown).getByText('Please select a visit type the list')).toBeVisible();
      fireEvent.click(getByText('Please select a visit type the list'));
      const opt = screen.getByText('Molina Follow-up Visit');

      fireEvent.click(opt);
      expect(within(visitDropdown).getByText('Molina Follow-up Visit')).toBeVisible();

      expect(within(screen.getByTestId('services-group')).getByText('Molina Visit Form (v031522)')).toBeVisible();

      const inputValue = screen.getByPlaceholderText('duration') as HTMLInputElement;

      expect(inputValue.value).toEqual('55');
    });

    it('adds service durations to the total calculated duration', async () => {
      const { getByText } = render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning />,
      );

      const visitDropdown = screen.getByTestId('visit_type_id');
      expect(within(visitDropdown).getByText('Please select a visit type the list')).toBeVisible();
      fireEvent.click(getByText('Please select a visit type the list'));
      const opt = screen.getByText('Molina Follow-up Visit');

      fireEvent.click(opt);
      expect(within(visitDropdown).getByText('Molina Follow-up Visit')).toBeVisible();

      const otherService = within(screen.getByTestId('services-group')).getByText('Molina: Telehealth ESCALATION Only');
      fireEvent.click(otherService);

      expect(otherService).toBeVisible();

      const inputValue = screen.getByPlaceholderText('duration') as HTMLInputElement;

      expect(inputValue.value).toEqual('70');
    });
  });

  describe('when patient has more than 1 program with multiple visit types', () => {
    const programs: Program[] = [
      {
        id: '1',
        name: 'Molina',
        active: true,
        services: [
          {
            id: '3',
            name: 'Molina: Telehealth ESCALATION Only',
            duration: '15',
          },
        ],
        visit_types: [
          {
            id: 9,
            name: 'Molina Follow-up Visit',
            alayacare_id: '8',
            duration: 15,
            services: [
              {
                id: '10',
                name: 'Molina Visit Form (v031522)',
                duration: '40',
              },
            ],
          },
          {
            id: 10,
            name: 'Molina Door to Door',
            alayacare_id: '7',
            duration: 30,
            services: [
              {
                id: '10',
                name: 'Molina Visit Form (v031522)',
                duration: '40',
              },
            ],
          },
        ],
      },
      {
        id: '2',
        name: 'Bright',
        active: true,
        services: [
          {
            id: '3',
            name: 'Bright Default Service',
            duration: '15',
          },
        ],
        visit_types: [
          {
            id: 9,
            name: 'Bright Visit Type',
            alayacare_id: '8',
            duration: 15,
            services: [
              {
                id: '10',
                name: 'Bright service',
                duration: '40',
              },
            ],
          },
        ],
      },
    ];
    it('should pre-select visit type if there is only 1 visit type', async () => {
      const { getByText } = render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning />,
      );

      const programDropdown = screen.getByTestId('program_id');

      expect(within(programDropdown).getByText('Please select a program from the list')).toBeVisible();

      fireEvent.click(getByText('Please select a program from the list'));

      const brightProgramOpt = screen.getByText('Bright');

      fireEvent.click(brightProgramOpt);

      const visitDropdown = screen.getByTestId('visit_type_id');
      // it should pre-select if program has only one visit type
      expect(within(visitDropdown).getByText('Bright Visit Type')).toBeVisible();
    });

    it('it calculates duration when selecting services', async () => {
      const { getByText } = render(
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        <CreateVisitModal programs={programs} closeModal={() => {}} patient={patient} editWarning />,
      );

      const programDropdown = screen.getByTestId('program_id');
      expect(within(programDropdown).getByText('Please select a program from the list')).toBeVisible();
      fireEvent.click(getByText('Please select a program from the list'));
      const brightProgramOpt = screen.getByText('Bright');
      fireEvent.click(brightProgramOpt);

      const otherService = within(screen.getByTestId('services-group')).getByText('Bright Default Service');
      fireEvent.click(otherService);
      expect(otherService).toBeVisible();

      const inputValue = screen.getByPlaceholderText('duration') as HTMLInputElement;

      expect(inputValue.value).toEqual('70');
    });
  });
});
