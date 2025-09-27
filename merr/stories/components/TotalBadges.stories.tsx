import React from 'react';
import { Story, Meta } from '@storybook/react';
import { TotalBadges, TotalBadgesProps } from '@/common/components/TotalBadges/TotalBadges';

export default {
  title: 'Components/TotalBadges',
  component: TotalBadges,
} as Meta;

const totalBadges = [
  {
    title: 'total',
    value: 24,
    color: '#0820c5',
  },
  {
    title: 'plus ones',
    value: 2,
    color: '#e39029',
  },
  {
    title: 'vaccines',
    value: 26,
    color: '#00a68c',
  },
];

const Template: Story<TotalBadgesProps> = (args) => <TotalBadges {...args} />;

export const Default = Template.bind({});

Default.args = {
  data: totalBadges,
};
