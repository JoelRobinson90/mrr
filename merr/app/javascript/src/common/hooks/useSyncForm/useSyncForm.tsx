import { useCallback, useState } from 'react';
import { FieldValues, SubmitHandler, useForm, UseFormMethods, UseFormOptions } from 'react-hook-form';

import {
  OriginalSubmittedValues,
  submitSyncForm,
  SubmitSyncFormOptions,
} from '@/common/components/SyncForm/SyncForm-utils';
import { SyncFormProps } from '@/common/components/SyncForm/SyncForm';

type SyncFormPropsWithoutChildren<T> = Omit<SyncFormProps<T>, 'children'>;

// TODO: solve problem with dynamic URLs
// url prop is required but dynamic URLs are handled with onFormSubmit instead
type UseSyncFormArgs<TFieldValues extends FieldValues = FieldValues> = SubmitSyncFormOptions & {
  url: string;
  method: string;
  disabled?: boolean;
  formOptions?: UseFormOptions<TFieldValues>;
  formId?: string;
  onFormSubmit?: SubmitHandler<TFieldValues>;
};

type UseSyncFormReturn<TFieldValues extends FieldValues> = {
  submit: (values: OriginalSubmittedValues) => void;
  syncFormProps: SyncFormPropsWithoutChildren<TFieldValues>;
  loading: boolean;
  form: UseFormMethods<TFieldValues>;
};

export function useSyncForm<TFieldValues extends FieldValues = FieldValues>({
  url,
  method,
  formId,
  disabled,
  formOptions,
  onFormSubmit,
  ...submitSyncFormOptions
}: UseSyncFormArgs<TFieldValues>): UseSyncFormReturn<TFieldValues> {
  const [loading, setLoading] = useState(false);

  const form = useForm<TFieldValues>(formOptions);

  const submit = useCallback(
    (values: OriginalSubmittedValues): void => {
      if (disabled || loading) {
        return;
      }

      setLoading(true);
      submitSyncForm(url, method, values, submitSyncFormOptions);
    },
    [disabled, loading, form.formState.isSubmitted],
  );

  const syncFormProps: SyncFormPropsWithoutChildren<TFieldValues> = {
    url,
    method,
    form,
    id: formId,
    onSubmit: (values) => (onFormSubmit ? onFormSubmit(values) : submit(values)),
  };

  return { submit, syncFormProps, loading, form };
}
