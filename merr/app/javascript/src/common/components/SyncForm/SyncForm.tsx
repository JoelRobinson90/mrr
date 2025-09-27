import React, { ReactNode } from 'react';
import { EuiForm } from '@elastic/eui';
import { FormProvider, useForm, UseFormMethods } from 'react-hook-form';

import { OriginalSubmittedValues, submitSyncForm, SubmitSyncFormOptions } from './SyncForm-utils';

export type SyncFormProps<S> = SubmitSyncFormOptions & {
  children: ReactNode;
  url: string;
  method: string;
  form?: UseFormMethods<S>;
  disabled?: boolean;
  id?: string;
  onSubmit?: (S) => void;
};

export function SyncForm<S>({
  children,
  url,
  method,
  form,
  disabled,
  id,
  onSubmit,
  ...submitOptions
}: SyncFormProps<S>): JSX.Element {
  form = form || useForm();
  const { handleSubmit } = form;

  const onFormSubmit = (values: OriginalSubmittedValues): void => {
    if (disabled) {
      return;
    }

    onSubmit ? onSubmit(values) : submitSyncForm(url, method, values, submitOptions);
  };

  return (
    <FormProvider {...form}>
      <EuiForm component="form" id={id} onSubmit={handleSubmit(onFormSubmit)}>
        {children}
      </EuiForm>
    </FormProvider>
  );
}
