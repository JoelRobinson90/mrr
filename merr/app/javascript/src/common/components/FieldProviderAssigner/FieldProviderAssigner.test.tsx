import { submitFormBy } from '@/../test_utils/helpers/renderTestForm';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';
import { admin_appointment_path } from '@/common/routes';
import { FieldProvider } from '@/common/types';
import { render, waitFor, fireEvent } from '@testing-library/react';
import React from 'react';
import { FieldProviderAssigner } from './FieldProviderAssigner';

jest.mock('@/common/components/SyncForm/SyncForm-utils', () => ({
  submitSyncForm: jest.fn(),
}));

const id = '1';
const field_provider = {
  bio: null,
  created_at: '2021-03-25T21:15:08.115Z',
  display_name: 'Adella Koch',
  email: null,
  first_name: 'Adella',
  id: 106,
  last_name: 'Koch',
  phone: null,
  provider_level: 'Paramedic',
  updated_at: '2021-03-25T21:15:08.115Z',
};
const field_providers: FieldProvider[] = [field_provider];
const fieldName = 'field_provider_id';

describe('Common/FieldProviderAssigner', () => {
  it('Unassigned Field Provider', async () => {
    const { getByText, container } = render(
      <FieldProviderAssigner
        submitUrl={admin_appointment_path(id)}
        fieldName={fieldName}
        formMethod="put"
        fieldProviders={field_providers}
        submitButtonLabel="Assign Field Provider"
      />,
    );

    submitFormBy(getByText('Assign Field Provider'));

    await waitFor(() => container);

    expect(submitSyncForm).toBeCalledWith(
      admin_appointment_path(id),
      'put',
      {
        field_provider_id: [],
      },
      { multipart: undefined },
    );
  });

  it('Checking assign Field Provider', async () => {
    const { getByText, container } = render(
      <FieldProviderAssigner
        submitUrl={admin_appointment_path(id)}
        fieldName={fieldName}
        formMethod="put"
        fieldProviders={field_providers}
        selectedFieldProvider={field_provider}
        submitButtonLabel="Assign Field Provider"
      />,
    );

    submitFormBy(getByText('Assign Field Provider'));

    await waitFor(() => container);

    expect(submitSyncForm).toBeCalledWith(
      admin_appointment_path(id),
      'put',
      {
        field_provider_id: field_provider.id,
      },
      { multipart: undefined },
    );
  });

  it('Assign Field Provider', async () => {
    const { getByText, container } = render(
      <FieldProviderAssigner
        submitUrl={admin_appointment_path(id)}
        fieldName={fieldName}
        formMethod="put"
        fieldProviders={field_providers}
        submitButtonLabel="Assign Field Provider"
      />,
    );

    const field: HTMLTextAreaElement = container.querySelector('[data-test-subj="comboBoxInput"]');
    fireEvent.click(field);
    fireEvent.click(getByText(field_provider.display_name));
    submitFormBy(getByText('Assign Field Provider'));

    await waitFor(() => container);

    expect(submitSyncForm).toBeCalledWith(
      admin_appointment_path(id),
      'put',
      {
        field_provider_id: [field_provider.id],
      },
      { multipart: undefined },
    );
  });
});
