import { MedSwitch, MedSwitchProps } from '@/common/components/forms';
import { EuiButton, EuiSpacer } from '@elastic/eui';
import { Story, Meta } from '@storybook/react';
import React from 'react';
import { FormProvider, useForm } from 'react-hook-form';

export default {
  title: 'Components/Form Fields/MedSwitch',
  component: MedSwitch,
} as Meta;

export const Default: Story<MedSwitchProps> = () => {
  const form = useForm({
    defaultValues: {
      standardToggle: false,
      defaultTrue: true,
      disabledToggle: true,
      standardToggleCompressed: false,
      defaultTrueCompressed: true,
      disabledToggleCompressed: true,
    },
  });

  const onSubmit = (values) => {
    alert(JSON.stringify(values));
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedSwitch name="standardToggle" label="Standard toggle" />
        <EuiSpacer size="s" />
        <MedSwitch name="defaultTrue" label="Defaults to true" color="secondary" />
        <EuiSpacer size="s" />
        <MedSwitch name="disabledToggle" disabled label="Disabled" />
        <EuiSpacer size="s" />

        <MedSwitch name="standardToggleCompressed" compressed label="Standard toggle (compressed)" />
        <EuiSpacer size="s" />
        <MedSwitch name="defaultTrueCompressed" compressed label="Defaults to true (compressed)" />
        <EuiSpacer size="s" />
        <MedSwitch name="disabledToggleCompressed" compressed disabled label="Disabled (compressed)" />
        <EuiSpacer size="s" />
      </FormProvider>
      <EuiButton type="submit">Submit</EuiButton>
    </form>
  );
};
