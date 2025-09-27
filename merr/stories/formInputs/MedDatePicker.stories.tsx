import React from 'react';
import { Story, Meta } from '@storybook/react';
import { useForm } from 'react-hook-form';

import { MedDatePicker, MedDatePickerProps } from '@/common/components/forms/MedDatePicker/MedDatePicker';

export default {
  title: 'Components/Form Fields/MedDatePicker',
  component: MedDatePicker,
  argTypes: {},
} as Meta;

interface ExtraProps {
  initialValue: string;
}

const Template: Story<MedDatePickerProps & ExtraProps> = ({ initialValue, ...props }) => {
  const form = useForm({
    defaultValues: {
      [props.name]: initialValue,
    },
  });

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <MedDatePicker form={form} {...props} />
    </form>
  );
};

export const Default = Template.bind({});
Default.args = {
  name: 'patient.date_of_birth',
  label: 'Date of birth',
  initialValue: '03/13/1987',
} as MedDatePickerProps & ExtraProps;
