import React, { ReactNode } from 'react';
import { EuiForm } from '@elastic/eui';
import { FormProvider, UseFormMethods } from 'react-hook-form';

export type MedFormProps<S> = {
  children: ReactNode;
  form: UseFormMethods<S>;
  id?: string;
  onSubmit?: (S) => void;
};

export function MedForm<S>({ children, form, id, onSubmit }: MedFormProps<S>): JSX.Element {
  const { handleSubmit } = form;
  return (
    <FormProvider {...form}>
      <EuiForm component="form" id={id} onSubmit={handleSubmit(onSubmit)}>
        {children}
      </EuiForm>
    </FormProvider>
  );
}
