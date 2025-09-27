import React from 'react';
import { get } from 'lodash';
import { EuiFieldPassword, EuiFieldPasswordProps, EuiFormRow } from '@elastic/eui';
import { useFormContext } from 'react-hook-form';

export interface MedPasswordFieldProps extends EuiFieldPasswordProps {
  label?: string;
  helpText?: string;
}

export const MedPasswordField: React.FC<MedPasswordFieldProps> = ({ label, helpText, name, ...fieldProps }) => {
  const { register, errors } = useFormContext();

  return (
    <EuiFormRow
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      helpText={helpText}
      fullWidth={fieldProps.fullWidth}
    >
      <EuiFieldPassword name={name} inputRef={register} isInvalid={!!get(errors, name)} {...fieldProps} />
    </EuiFormRow>
  );
};
