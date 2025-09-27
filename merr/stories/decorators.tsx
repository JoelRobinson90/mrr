import React from 'react';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';

export const FormFieldDecorator = (Story) => {
  const form = useForm();

  return (
    <SyncForm url="/" method="get" form={form}>
      <Story />
    </SyncForm>
  );
};
