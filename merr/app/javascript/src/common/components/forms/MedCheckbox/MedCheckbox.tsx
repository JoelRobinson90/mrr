import React from 'react';
import { EuiCheckbox, EuiCheckboxProps } from '@elastic/eui';
import { Controller, useFormContext } from 'react-hook-form';

export type MedCheckboxProps = Omit<EuiCheckboxProps, 'id' | 'onChange'>;

export const MedCheckbox: React.FC<MedCheckboxProps> = ({ name, ...checkboxProps }) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      render={({ onChange, value }) => (
        <EuiCheckbox
          id={name}
          checked={value}
          onChange={(event) => onChange(event.currentTarget.checked)}
          {...checkboxProps}
        />
      )}
    />
  );
};
