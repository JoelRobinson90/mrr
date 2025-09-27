import React from 'react';
import { Story, Meta } from '@storybook/react';
import * as yup from 'yup';
import { FormProvider, useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers';

import { MedTextField, MedTextFieldProps } from '@/common/components/forms';

export default {
  title: 'Components/Form Fields/MedTextField',
  component: MedTextField,
  argTypes: {
    disabled: {
      type: 'boolean',
    },
    readOnly: {
      type: 'boolean',
    },
    isLoading: {
      type: 'boolean',
    },
    fullWidth: {
      type: 'boolean',
    },
    compressed: {
      type: 'boolean',
    },
  },
} as Meta;

const schema = yup.object().shape({
  first_name: yup.string().label('First name').required(),
});

const Template: Story<MedTextFieldProps> = (props) => {
  const form = useForm({
    defaultValues: {
      first_name: 'Erik',
    },
    resolver: yupResolver(schema),
    mode: 'all',
  });

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedTextField name="first_name" {...props} />
      </FormProvider>
    </form>
  );
};

export const Default = Template.bind({});
Default.args = {
  label: 'First Name',
  placeholder: "Enter the patient's first name",
  helpText: 'This is help text. Clear the field to see the invalid state.',
};
