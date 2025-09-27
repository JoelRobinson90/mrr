import React from 'react';
import { MedCheckbox, MedCheckboxProps } from '@/common/components/forms';
import { Meta, Story } from '@storybook/react';
import { FormProvider, useForm } from 'react-hook-form';
import { EuiButton, EuiSpacer } from '@elastic/eui';

export default {
  title: 'Components/Form Fields/MedCheckbox',
  component: MedCheckbox,
  argTypes: {},
} as Meta;

export const Default: Story<MedCheckboxProps> = () => {
  const form = useForm({
    defaultValues: {
      box1: true,
      box2: false,
      disabledBox: true,
      compressedBox: false,
    },
  });

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedCheckbox name="box1" label="I am a checkbox" />

        <EuiSpacer size="m" />

        <MedCheckbox name="box2" label="I am also a checkbox" />

        <EuiSpacer size="m" />

        <MedCheckbox name="disabledBox" disabled label="I am a disabled checkbox" />

        <EuiSpacer size="m" />

        <MedCheckbox name="compressedBox" compressed label="I am a compressed checkbox" />
      </FormProvider>

      <EuiSpacer size="m" />

      <EuiButton type="submit" fill>
        Submit
      </EuiButton>
    </form>
  );
};
