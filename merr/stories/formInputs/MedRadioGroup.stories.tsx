import React from 'react';
import { MedRadioGroup, MedRadioGroupProps } from '@/common/components/forms';
import { Meta, Story } from '@storybook/react';
import { FormProvider, useForm } from 'react-hook-form';
import { EuiButton, EuiSpacer } from '@elastic/eui';

export default {
  title: 'Components/Form Fields/MedRadioGroup',
  component: MedRadioGroup,
  argTypes: {},
} as Meta;

export const Default: Story<MedRadioGroupProps> = () => {
  const form = useForm({
    defaultValues: {
      selectedId: 'option1',
    },
  });

  const radios: MedRadioGroupProps['options'] = [
    {
      id: 'option1',
      label: 'This is radio 1',
    },
    {
      id: 'option2',
      label: 'This is radio 2',
    },
    {
      id: 'disabled',
      label: 'This is a disabled radio',
      disabled: true,
    },
  ];

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedRadioGroup name="selectedId" options={radios} />
      </FormProvider>

      <EuiSpacer size="m" />

      <EuiButton type="submit" fill>
        Submit
      </EuiButton>
    </form>
  );
};
