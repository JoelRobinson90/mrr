import React from 'react';
import { EuiFieldNumber, EuiFieldNumberProps, EuiFormRow } from '@elastic/eui';
import { get } from 'lodash';
import { useFormContext } from 'react-hook-form';

export interface MedNumberFieldProps extends EuiFieldNumberProps {
  label?: string;
  helpText?: string;
}

export const MedNumberField: React.FC<MedNumberFieldProps> = ({ label, helpText, name, ...fieldProps }) => {
  const { register, errors } = useFormContext();

  return (
    <EuiFormRow
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      helpText={helpText}
      fullWidth={fieldProps.fullWidth}
      className={fieldProps.className}
      hidden={fieldProps.hidden}
    >
      <EuiFieldNumber name={name} inputRef={register} isInvalid={!!get(errors, name)} {...fieldProps} />
    </EuiFormRow>
  );
};
