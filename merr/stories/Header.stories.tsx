import React from 'react';
import { Story, Meta } from '@storybook/react';
import { EuiHeader, EuiHeaderLogo, EuiHeaderSectionItemButton, EuiIcon, EuiHeaderProps } from '@elastic/eui';

export default {
  title: 'Components/Header',
  component: EuiHeader,
} as Meta;

const Template: Story<EuiHeaderProps> = (args) => <EuiHeader {...args} />;

export const Default = Template.bind({});

const renderLogo = (
  <EuiHeaderLogo iconType="logoElastic" href="#" onClick={(e) => e.preventDefault()} aria-label="Go to home page" />
);
const renderApps = (
  <EuiHeaderSectionItemButton aria-label="Apps menu with 1 new app" notification="1">
    <EuiIcon type="apps" size="m" />
  </EuiHeaderSectionItemButton>
);

const breadcrumbs = [
  {
    text: 'Patients',
    href: '#',
    onClick: (e) => {
      e.preventDefault();
    },
  },
  {
    text: 'All Patients',
    href: '#',
    onClick: (e) => {
      e.preventDefault();
    },
  },
];

const sections = [
  {
    items: [renderLogo],
    borders: 'right',
    breadcrumbs: breadcrumbs,
    breadcrumbProps: {
      'aria-label': 'Header sections breadcrumbs',
    },
  },
  {
    items: [renderApps],
  },
];

Default.args = {
  sections,
};
