import React from 'react';
import { Story, Meta } from '@storybook/react';
import { MedStatusDropdown, MedStatusDropdownProps } from '@/common/components/MedStatusDropdown/MedStatusDropdown';

export default {
  title: 'Components/MedStatusDropdown',
  component: MedStatusDropdown,
} as Meta;

const Template: Story<MedStatusDropdownProps> = (args) => <MedStatusDropdown {...args} />;

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

Default.args = {
  status: 'Assigned',
  statuses: STATUSES,
  url: '',
  defaultValues: {},
  name: '',
};
