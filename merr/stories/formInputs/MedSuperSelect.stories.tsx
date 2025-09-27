import React from 'react';
import { Story, Meta } from '@storybook/react';
import { EuiHealth } from '@elastic/eui';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { MedSuperSelect, MedSuperSelectProps } from '@/common/components/forms/MedSuperSelect/MedSuperSelect';
import { STATUS_COLOR_MAP } from '@/common/components/MedBadge/MedBadge';
import { useForm } from 'react-hook-form';

export default {
  title: 'Components/Form Fields/MedSuperSelect',
  component: MedSuperSelect,
} as Meta;

type ExtraProps = {
  initialValue: string;
};

const Template: Story<MedSuperSelectProps & ExtraProps> = ({ initialValue, ...args }) => {
  const defaultValues = {
    [args.name]: initialValue,
  };

  const form = useForm({
    defaultValues,
  });

  return (
    // @ts-ignore
    <SyncForm url="/" form={form} disabled>
      <MedSuperSelect {...args} />
    </SyncForm>
  );
};

export const Default = Template.bind({});

const STATUSES = [
  'Created',
  'Assigned',
  'Awaiting Scheduling',
  'Canceled',
  'Complete',
  'In Progress',
  'Issue',
  'Pending Acceptance',
  'Alayacare',
  'Vacant',
];

const options = STATUSES.map((value) => ({
  value,
  inputDisplay: (
    <EuiHealth color={STATUS_COLOR_MAP[value]} style={{ lineHeight: 'inherit' }}>
      {value}
    </EuiHealth>
  ),
}));

Default.args = {
  name: 'super_select',
  width: '200px',
  options,
  initialValue: STATUSES[0],
};
