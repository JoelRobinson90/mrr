import React from 'react';
import { EuiFormRow, EuiSuperSelectProps, EuiSuperSelect } from '@elastic/eui';
import { get } from 'lodash';
import { Controller, useFormContext } from 'react-hook-form';

export interface MedSuperSelectProps extends EuiSuperSelectProps<string> {
  label?: string;
  width?: string;
}

export const MedSuperSelect: React.FC<MedSuperSelectProps> = ({ label, name, ...selectProps }) => {
  const { errors, control } = useFormContext();

  return (
    <EuiFormRow
      className={selectProps.className}
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      fullWidth={selectProps.fullWidth}
      style={{ width: selectProps.width }}
    >
      <Controller
        name={name}
        control={control}
        render={({ onChange, value }) => (
          <EuiSuperSelect
            isInvalid={!!get(errors, name)}
            valueOfSelected={value}
            onChange={onChange}
            {...selectProps}
          />
        )}
      />
    </EuiFormRow>
  );
};
