import React from 'react';
import { Story, Meta } from '@storybook/react';
import { EuiButton } from '@elastic/eui';
import { FormProvider, useForm } from 'react-hook-form';
import { MedSelect, MedSelectProps } from '@/common/components/forms';

const defaultOptions: MedSelectProps['options'] = [
  { value: 'apple_value', text: 'Apple' },
  { value: 'banana_value', text: 'Banana' },
  { value: 'cucumber_value', text: 'Cucumber' },
];

export default {
  title: 'Components/Form Fields/MedSelect',
  component: MedSelect,
  argTypes: {
    name: {
      type: 'string',
      defaultValue: 'patient.favorite_fruit',
    },
    options: {
      defaultValue: defaultOptions,
    },
    disabled: {
      type: 'boolean',
    },
    isLoading: {
      type: 'boolean',
    },
    isInvalid: {
      type: 'boolean',
    },
    fullWidth: {
      type: 'boolean',
    },
    compressed: {
      type: 'boolean',
    },
    hasNoInitialSelection: {
      type: 'boolean',
    },
  },
} as Meta;

const Template: Story<MedSelectProps> = (args) => {
  const form = useForm({
    defaultValues: {
      [args.name]: 'cucumber_value',
    },
  });

  return (
    <FormProvider {...form}>
      <form onSubmit={form.handleSubmit((values) => alert(JSON.stringify(values)))}>
        <MedSelect name="patient.favorite_fruit" {...args} />
        <EuiButton type="submit">Submit</EuiButton>
      </form>
    </FormProvider>
  );
};

export const Default = Template.bind({});

export const Prepend = Template.bind({});
Prepend.args = {
  prepend: 'Prepend',
} as MedSelectProps;

export const Append = Template.bind({});
Append.args = {
  append: 'Append',
} as MedSelectProps;
