import React from 'react';
import { Story, Meta } from '@storybook/react';
import { EuiFieldSearch, EuiFieldSearchProps } from '@elastic/eui';

export default {
  title: 'Components/Search/EuiSearch',
  component: EuiFieldSearch,
} as Meta;

const Template: Story<EuiFieldSearchProps> = (args) => <EuiFieldSearch {...args} />;

export const Default = Template.bind({});

Default.args = {
  placeholder: 'Search for patient by Patient ID #...',
};
