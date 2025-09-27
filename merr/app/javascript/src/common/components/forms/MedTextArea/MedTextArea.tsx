import React from 'react';
import { EuiTextArea, EuiTextAreaProps, EuiFormRow } from '@elastic/eui';
import { get } from 'lodash';
import { useFormContext } from 'react-hook-form';

export interface MedTextAreaProps extends EuiTextAreaProps {
  label?: string;
  helpText?: string;
  width?: string;
}

export const MedTextArea: React.FC<MedTextAreaProps> = ({ label, helpText, name, ...fieldProps }) => {
  const { register, errors } = useFormContext();

  return (
    <EuiFormRow
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      helpText={helpText}
      fullWidth={fieldProps.fullWidth}
      style={{ width: fieldProps.width, marginTop: 0 }}
    >
      <EuiTextArea name={name} inputRef={register} isInvalid={!!get(errors, name)} {...fieldProps} />
    </EuiFormRow>
  );
};
