import { Meta, Story } from '@storybook/react';
import React from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers';
import { MedMaskedInput } from '@/common/components/forms';
import { Patient } from '@/common/types';
import { dashDateToSlashDate, DASH_DATE_REGEX, slashDateToDashDate } from '@/common/utils/dates/dates';

const schema = yup.object().shape({
  patient: yup.object().shape({
    date_of_birth: yup.string().transform(slashDateToDashDate).matches(DASH_DATE_REGEX, 'Must be a valid date'),
  }),
});

export default {
  title: 'Components/Form Fields/MedMaskedInput',
  component: MedMaskedInput,
  argTypes: {},
} as Meta;

const transformPatientToForm = ({ date_of_birth, ...patient }: Patient): Patient => ({
  ...patient,
  date_of_birth: dashDateToSlashDate(date_of_birth),
});

export const DateOfBirth: Story = () => {
  const form = useForm();

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedMaskedInput
          mask="99/99/9999"
          name="patient.date_of_birth"
          label="Date of birth"
          icon="calendar"
          helpText="Date format in MM/DD/YYYY"
        />
      </FormProvider>
    </form>
  );
};

export const DateOfBirthWithTransform: Story = () => {
  const patient: Patient = {
    id: 1,
    first_name: 'Erik',
    last_name: 'Ly',
    medical_record_number: '123',
  };

  const transformedPatient = transformPatientToForm(patient);

  const form = useForm({
    defaultValues: {
      patient: transformedPatient,
    },
    resolver: yupResolver(schema),
  });

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedMaskedInput
          mask="99/99/9999"
          name="patient.date_of_birth"
          label="Date of birth"
          icon="calendar"
          helpText="Date format in MM/DD/YYYY"
        />
      </FormProvider>
    </form>
  );
};

export const DateOfBirthWithDefaultValueAndTransform: Story = () => {
  const patient: Patient = {
    id: 1,
    first_name: 'Erik',
    last_name: 'Ly',
    medical_record_number: '123',
    date_of_birth: '1987-03-13',
  };

  const transformedPatient = transformPatientToForm(patient);

  const form = useForm({
    defaultValues: {
      patient: transformedPatient,
    },
    resolver: yupResolver(schema),
  });

  const onSubmit = (values) => alert(JSON.stringify(values));

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <FormProvider {...form}>
        <MedMaskedInput
          mask="99/99/9999"
          name="patient.date_of_birth"
          label="Date of birth"
          icon="calendar"
          helpText="Date format in MM/DD/YYYY"
        />
      </FormProvider>
    </form>
  );
};
