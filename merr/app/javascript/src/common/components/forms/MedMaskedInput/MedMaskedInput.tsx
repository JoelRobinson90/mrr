import { EuiFieldText, EuiFieldTextProps, EuiFormRow } from '@elastic/eui';
import { get } from 'lodash';
import React from 'react';
import { Controller, useFormContext } from 'react-hook-form';
import InputMask from 'react-input-mask';

export interface MedMaskedInputProps extends EuiFieldTextProps {
  mask: string;
  label?: string;
  helpText?: string;
}

export const MedMaskedInput: React.FC<MedMaskedInputProps> = ({
  mask,
  label,
  helpText,
  name,
  defaultValue,
  ...fieldProps
}) => {
  const { errors, control } = useFormContext();

  return (
    <EuiFormRow
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      helpText={helpText}
      fullWidth={fieldProps.fullWidth}
    >
      <Controller
        name={name}
        control={control}
        defaultValue={defaultValue}
        render={({ onChange, value }) => (
          <InputMask mask={mask} value={value} onChange={onChange}>
            <EuiFieldText name={name} isInvalid={!!get(errors, name)} {...fieldProps} />
          </InputMask>
        )}
      />
    </EuiFormRow>
  );
};
