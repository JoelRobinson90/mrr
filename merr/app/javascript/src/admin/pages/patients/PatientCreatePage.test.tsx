import React from 'react';
import { PatientInfoTab } from './PatientInfoTab';
import { screen, render } from '@testing-library/react';
import { AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';

describe('<PatientCreatePage />', () => {
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

    const phone_types = ['Cell', 'Home', 'Work'];
    const demand_partners = [{ id: 1, name: 'Molina' }];
    const genders = ['Man', 'Women', 'Transgender', 'Unknown'];
    const sexes = ['Male', 'Female', 'Unknown'];
    const languages = ['English', 'Spanish'];

    const user = {
      id: 1,
      email: 'test@example.com',
      created_at: '2021-03-25T12:05:05.912Z',
      updated_at: '2021-03-25T12:05:05.912Z',
      authentication_token: 'xxx222222',
      authentication_token_created_at: '2021-03-25T12:05:05.910Z',
      has_random_password: true,
      account_id: 355,
      account_type: 'Patient',
      deactivated: false,
      account: {},
    };
    const address = {
      id: 2,
      address_line_one: 'street 1',
      address_line_two: '2',
      city: 'New York',
      county: 'New York',
      state: 'New York',
      zipcode: '10016',
      created_at: '2021-03-25T12:05:05.882Z',
      updated_at: '2021-03-25T12:05:05.882Z',
      latitude: null,
      longitude: null,
      notes: null,
      timezone: null,
      addressable_type: 'Patient',
      addressable_id: 355,
    };
    render(
      <PatientInfoTab
        demand_partners={demand_partners}
        genders={genders}
        sexes={sexes}
        languages={languages}
        user={user}
        address={address}
        patient={patient}
        phone_types={phone_types}
        programs={[{ id: '1', name: 'Molina', services: [] }]}
      />,
    );

    const items = await screen.getAllByText(`${patient.first_name}`);

    items.forEach((item) => expect(item).toBeInTheDocument());
  });
});

// @TODO: test validations
