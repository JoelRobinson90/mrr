import { Meta, Story } from '@storybook/react';
import React, { useState } from 'react';
import { MedButtonOnce, MedButtonOnceProps } from '@/common/components/MedButtonOnce/MedButtonOnce';
import { EuiText } from '@elastic/eui';

export default {
  title: 'Components/MedButtonOnce',
  component: MedButtonOnce,
  argTypes: {
    initialButtonText: {
      type: 'string',
      defaultValue: 'Initial button text',
    },
    loadingText: {
      type: 'string',
    },
    color: {
      type: 'string',
      defaultValue: 'primary',
    },
    fill: {
      type: 'boolean',
    },
  },
} as Meta;

const Template: Story<MedButtonOnceProps & { initialButtonText: string }> = ({ initialButtonText, ...buttonProps }) => {
  const [counter, setCounter] = useState(0);

  const onClick = () => {
    console.log('setting counter to', counter + 1);
    setCounter(counter + 1);
  };

  return (
    <>
      <MedButtonOnce {...buttonProps} onClick={onClick}>
        {initialButtonText}
      </MedButtonOnce>
      <EuiText>Button clicked {counter} time(s)</EuiText>
    </>
  );
};

export const Default = Template.bind({});
