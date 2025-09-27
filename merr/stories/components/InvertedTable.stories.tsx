import React from 'react';
import { Story, Meta } from '@storybook/react';
import { InvertedTable, DataRow, InvertedTableProps } from '@/admin/components/InvertedTable/InvertedTable';

export default {
  title: 'Components/InvertedTable/InvertedTable',
  component: InvertedTable,
} as Meta;

const dataItems: DataRow[] = [
  {
    name: 'Name',
    value: 'This Name',
  },
  {
    name: 'Category',
    value: 'This Category',
  },
  {
    name: 'Description',
    render: 'This Description',
  },
];

const Template: Story<InvertedTableProps> = (args) => <InvertedTable items={dataItems} {...args} />;

export const Default = Template.bind({});

Default.args = {};
