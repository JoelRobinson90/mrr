import { EuiColorPicker, EuiFormRow } from '@elastic/eui';
import React from 'react';
import { Controller, useFormContext } from 'react-hook-form';
import { get } from 'lodash';

export interface MedColorPickerProps {
  name: string;
  label?: string;
}

export const MedColorPicker: React.FC<MedColorPickerProps> = ({ name, label }) => {
  const { control, errors } = useFormContext();

  return (
    <EuiFormRow label={label} isInvalid={!!get(errors, name)} error={get(errors, name)?.message}>
      <Controller
        name={name}
        control={control}
        render={({ onChange, value }) => {
          return <EuiColorPicker onChange={onChange} color={value} />;
        }}
      />
    </EuiFormRow>
  );
};
