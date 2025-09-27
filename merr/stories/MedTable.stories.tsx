import React from 'react';
import { EuiBadge } from '@elastic/eui';
import { Story, Meta } from '@storybook/react';
import { MedTable, MedTableProps } from '@/common/components/MedTable/MedTable';

export default {
  title: 'Components/Tables/MedTable',
  component: MedTable,
} as Meta;

type SampleTableItem = {
  name: string;
  number: string;
  phoneNumber: string;
  location: string;
  partner: string;
  status: string;
};

const Template: Story<MedTableProps<SampleTableItem>> = (args) => <MedTable {...args} />;

const PatientBadge = (status) => {
  const complete = status.toLowerCase() === 'scheduled' || status.toLowerCase() === 'completed';
  const color = complete ? 'hollow' : '#FA3106';

  return <EuiBadge color={color}>{status}</EuiBadge>;
};

export const Default = Template.bind({});
Default.args = {
  items: [
    {
      name: 'Harrison',
      number: '1',
      phoneNumber: '(541) 754-3010',
      location: 'Nairobi, Kenya',
      partner: 'partner-1',
      status: 'Awaiting',
    },
    {
      name: 'Erik',
      number: '2',
      phoneNumber: '(541) 754-3011',
      location: 'Dallas, Texas',
      partner: 'partner-2',
      status: 'Scheduled',
    },
    {
      name: 'Krishna',
      number: '3',
      phoneNumber: '(541) 754-3012',
      location: 'New York City, New York',
      partner: 'partner-3',
      status: 'Completed',
    },
    {
      name: 'Soren',
      number: '4',
      phoneNumber: '(541) 754-3013',
      location: 'San Francisco, California',
      partner: 'partner-4',
      status: 'Missing Data',
    },
  ],
  columns: [
    {
      field: 'name',
      name: 'Name',
      sortable: true,
    },
    {
      field: 'number',
      name: 'NO#',
      sortable: true,
    },
    {
      field: 'phoneNumber',
      name: 'Phone Number',
    },
    {
      field: 'location',
      name: 'City/State',
    },
    {
      field: 'partner',
      name: 'Partner',
    },
    {
      field: 'status',
      name: 'Status',
      render: (status) => {
        return PatientBadge(status);
      },
    },
  ],
};
