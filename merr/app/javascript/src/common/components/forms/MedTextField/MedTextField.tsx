import React from 'react';
import { EuiFieldText, EuiFieldTextProps, EuiFormRow } from '@elastic/eui';
import { get } from 'lodash';
import { useFormContext } from 'react-hook-form';

export interface MedTextFieldProps extends EuiFieldTextProps {
  label?: string;
  helpText?: string;
  placeholderText?: string;
}

export const MedTextField: React.FC<MedTextFieldProps> = ({
  label,
  helpText,
  name,
  placeholderText,
  ...fieldProps
}) => {
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
      <EuiFieldText
        placeholder={placeholderText}
        name={name}
        inputRef={register}
        isInvalid={!!get(errors, name)}
        {...fieldProps}
      />
    </EuiFormRow>
  );
};
