import { SyncForm } from '../../app/javascript/src/common/components/SyncForm/SyncForm';
import React from 'react';
import { Story, Meta } from '@storybook/react';
import { useForm } from 'react-hook-form';
import { EuiButton, EuiFlexGroup, EuiFlexItem, EuiSpacer } from '@elastic/eui';
import { MedComboBox, MedTextField } from '../../app/javascript/src/common/components/forms';

export default {
  title: 'Examples/Form Example',
} as Meta;

const tagIdsOptions = [
  { value: 1, label: 'Tag 1' },
  { value: 2, label: 'Tag 2' },
  { value: 3, label: 'Tag 3' },
];

export const FormExample: Story = () => {
  const form = useForm({
    defaultValues: {
      patient: {
        first_name: 'Erik',
        last_name: 'Lyngved',
        tag_ids: [3],
      },
    },
  });

  return (
    <SyncForm form={form} url={`/v/123/edit`} method="post">
      <EuiFlexGroup>
        <EuiFlexItem>
          <MedTextField name="patient.first_name" label="First name" />
        </EuiFlexItem>
        <EuiFlexItem>
          <MedTextField name="patient.last_name" label="Last name" />
        </EuiFlexItem>
      </EuiFlexGroup>

      <EuiSpacer />

      <MedComboBox name="patient.tag_ids" label="Tags" options={tagIdsOptions} placeholder="Select tags" />

      <EuiSpacer />

      <EuiButton type="submit" fill>
        Save patient
      </EuiButton>
    </SyncForm>
  );
};
