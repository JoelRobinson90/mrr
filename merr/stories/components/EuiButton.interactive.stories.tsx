import React from 'react';
import { Story, Meta } from '@storybook/react/types-6-0';
import { EuiButton, EuiButtonEmpty, EuiButtonEmptyProps, EuiButtonProps } from '@elastic/eui';

export default {
  title: 'Components/EuiButton/Interactive',
  component: EuiButton,
  argTypes: {
    children: {
      type: 'string',
      defaultValue: 'Button text',
    },
    color: {
      control: {
        type: 'select',
        options: ['primary', 'secondary', 'warning', 'danger', 'ghost'],
      },
      defaultValue: 'primary',
    },
    fill: {
      type: 'boolean',
    },
    fullWidth: {
      type: 'boolean',
    },
    size: {
      control: {
        type: 'select',
        options: ['m', 's'],
      },
    },
    disabled: {
      type: 'boolean',
    },
  },
} as Meta;

export const SimpleButton: Story<EuiButtonProps> = (props) => <EuiButton {...props} />;

export const EmptyButton: Story<EuiButtonEmptyProps> = (props) => <EuiButtonEmpty {...props} />;
