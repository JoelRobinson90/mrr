import React from 'react';
import { Story, Meta } from '@storybook/react';
import { EuiPagination } from '@elastic/eui';
import { EuiPaginationProps } from '@elastic/eui/src/components/pagination/pagination';

export default {
  title: 'Components/Pagination/EuiPagination',
  component: EuiPagination,
} as Meta;

const Template: Story<EuiPaginationProps> = (args) => <EuiPagination {...args} />;

export const Default = Template.bind({});

Default.args = {
  pageCount: 4,
  activePage: 1,
  // pageNumber is zero-indexed so it starts from zero
  onPageClick: (pageNumber) => alert(`Page clicked: ${pageNumber + 1}`),
};
