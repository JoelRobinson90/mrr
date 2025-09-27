import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react';
import { AppointmentShowPage } from './AppointmentShowPage';
import { buildAdminNote, buildAppointment, buildSurvey } from '@/../test_utils/factories';
import { AppointmentEditPartial } from '@/admin/pages/appointments/AppointmentEditPartial';
import { registerPartials } from '@/common/components/RemotePartial/RemotePartial';
import { submitFormBy } from '@/../test_utils/helpers/renderTestForm';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';
import { tags_admin_appointment_path } from '@/common/routes';
import { AdminAppContext } from '@/admin/components/AdminLayout/AdminLayout';
import { GetCurrentUserQuery } from '@/generated/graphql';

jest.mock('@/common/components/SyncForm/SyncForm-utils', () => ({
  submitSyncForm: jest.fn(),
}));

describe('Admin AppointmentShowPage', () => {
  const currentUser: GetCurrentUserQuery['getCurrentUser'] = {
    __typename: 'User',
    id: 'test-user-id',
    email: 'admin@medarrive.com',
    displayName: 'Admin User',
    account: {
      __typename: 'MedarriveAdmin',
      firstName: 'Admin',
      lastName: 'User',
    },
  };

  it('correctly displays the papertrail history events', () => {
    const appointment = buildAppointment({
      status: 'Assigned',
      tag_list: ['tag1'],
    });

    const events: Array<[string, Array<string>]> = [
      [
        'On Monday, 03 May 2021 at 3:27 PM, *MedArrive System* created the following Appointment info:',
        [' status: Assigned'],
      ],
    ];

    const fieldProviders = [
      {
        id: 1,
        first_name: 'Jon',
        last_name: 'Doe',
        bio: '',
        provider_level: '',
        display_name: 'Jon Doe',
        email: 'jon@example.com',
        phone: '2055551234',
      },
      {
        id: 2,
        first_name: 'Jane',
        last_name: 'Doe',
        bio: '',
        provider_level: '',
        display_name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '2055551234',
      },
    ];

    const { queryByText } = render(
      <AdminAppContext.Provider value={{ currentUser }}>
        <AppointmentShowPage
          layout_props={{}}
          appointment={appointment}
          available_tags={['tag1', 'tag2']}
          statuses={['Assigned', 'Available']}
          paper_trail={events}
          field_providers={fieldProviders}
        />
      </AdminAppContext.Provider>,
    );
    expect(queryByText(/Monday, May 3rd, 2021 3:27pm/)).toBeInTheDocument();
  });

  it('renders an admin note with default System User creator', () => {
    const appointment = buildAppointment({
      admin_notes: [
        buildAdminNote({
          creator: null,
        }),
      ],
    });

    const { getByText } = render(
      <AdminAppContext.Provider value={{ currentUser }}>
        <AppointmentShowPage
          layout_props={{}}
          appointment={appointment}
          available_tags={[]}
          statuses={[]}
          paper_trail={[]}
          field_providers={[]}
        />
      </AdminAppContext.Provider>,
    );

    expect(getByText('System User')).toBeInTheDocument();
  });

  describe('Additional Data Collection', () => {
    it('renders additional data collection needed', () => {
      const appointment = buildAppointment({
        available_surveys: [
          buildSurvey({
            name: 'survey_one',
            meta: {
              title: 'Survey 1',
            },
            responded: true,
          }),
          buildSurvey({
            name: 'survey_two',
            meta: {
              title: 'Survey 2',
            },
            responded: false,
          }),
        ],
        hra_survey_status: 'Complete',
      });

      const { getByText } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={[]}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      expect(getByText('Survey 1: Complete')).toBeInTheDocument();
      expect(getByText('Survey 2: Pending')).toBeInTheDocument();
      expect(getByText('SCAN HRA Survey: Complete')).toBeInTheDocument();
    });

    it('does not render HRA survey if not required', () => {
      const appointment = buildAppointment({
        available_surveys: [],
        hra_survey_status: 'Not Required',
      });

      const { getByText, queryByText } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={[]}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      expect(getByText('Additional Data Collection')).toBeInTheDocument();
      expect(queryByText(/SCAN HRA Survey/)).not.toBeInTheDocument();
    });
  });

  describe('Forms submission', () => {
    const appointment = buildAppointment({
      status: 'Assigned',
      tag_list: ['tag1'],
    });
    const availableTags = ['1st attempt', 'Vaccinated', '4th attempt'];

    const oldFetch = window.fetch;

    beforeEach(() => {
      delete window.fetch;
    });

    afterEach(() => {
      window.fetch = oldFetch;
    });

    registerPartials({ AppointmentEditPartial });

    const fetchMock = jest.fn(() =>
      Promise.resolve({
        status: 200,
        json: () =>
          Promise.resolve({
            componentName: 'AppointmentEditPartial',
            componentProps: {
              appointment: appointment,
              available_tags: availableTags,
            },
          }),
      }),
    );

    beforeEach(() => {
      // @ts-ignore
      window.fetch = fetchMock;
    });

    it('Open Flyout Edit Appointment', async () => {
      const { queryByText, findAllByTestId } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={[]}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      fireEvent.click(queryByText('Edit Appointment'));
      const content = await findAllByTestId('HRA');
      expect(content[0]).toHaveTextContent('(Not counting extra recipients or HRA survey)');
    });

    it('Without Tags', async () => {
      const appointment = buildAppointment();

      const { getByText, container } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={[]}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      submitFormBy(getByText('Save Tags'));

      await waitFor(() => container);

      expect(submitSyncForm).toBeCalledWith(
        tags_admin_appointment_path(appointment.id),
        'post',
        {
          appointment: {
            tag_list: [],
          },
        },
        { multipart: undefined },
      );
    });

    it('Checking Tags', async () => {
      const appointment = buildAppointment({ tag_list: ['tag1', 'tag2'] });

      const { getByText, container } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={[]}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      submitFormBy(getByText('Save Tags'));

      await waitFor(() => container);

      expect(submitSyncForm).toBeCalledWith(
        tags_admin_appointment_path(appointment.id),
        'post',
        {
          appointment: {
            tag_list: ['tag1', 'tag2'],
          },
        },
        { multipart: undefined },
      );
    });

    it('Selects Tags', async () => {
      const appointment = buildAppointment();

      const { getByText, container } = render(
        <AdminAppContext.Provider value={{ currentUser }}>
          <AppointmentShowPage
            layout_props={{}}
            appointment={appointment}
            available_tags={['tag1']}
            statuses={[]}
            paper_trail={[]}
            field_providers={[]}
          />
        </AdminAppContext.Provider>,
      );

      const field: HTMLTextAreaElement = container.querySelector(
        '[data-testid="tags"] [data-test-subj="comboBoxInput"]',
      );
      fireEvent.click(field);
      fireEvent.click(getByText('tag1'));
      submitFormBy(getByText('Save Tags'));

      await waitFor(() => container);

      expect(submitSyncForm).toBeCalledWith(
        tags_admin_appointment_path(appointment.id),
        'post',
        {
          appointment: {
            tag_list: ['tag1'],
          },
        },
        { multipart: undefined },
      );
    });
  });
});
