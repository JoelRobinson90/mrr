import React from 'react';
import { AlayacareCreateVisit } from './AlayacareCreateVisit';
import { screen, render, act } from '@testing-library/react';
import { AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';
import { setInputValue } from '@/../test_utils/helpers/renderTestForm';

describe('<AlayacareCreateVisit />', () => {
  const oldFetch = window.fetch;

  beforeEach(() => {
    delete window.fetch;
  });

  afterEach(() => {
    window.fetch = oldFetch;
  });

  const fetchMock = jest.fn(() =>
    Promise.resolve({
      status: 200,
      json: () =>
        Promise.resolve({}),
    }),
  );

  beforeEach(() => {
    // @ts-ignore
    window.fetch = fetchMock;
  });

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

    const programs = [
      {
        id: '1',
        name: 'Bright',
        services: [],
      },
    ];
    const { container } = render(
      <AlayacareCreateVisit
        enable_form={true}
        patient={patient}
        layout_props={layoutProps}
        programs={programs}
        service_codes={[]}
      />,
    );

    const items = await screen.getAllByText(`${patient.first_name} ${patient.last_name}`);

    items.forEach((item) => expect(item).toBeInTheDocument());
    // @TODO: add more tests after finishing UI design
  });
});

// @TODO: test validations
