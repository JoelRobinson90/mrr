import React from 'react';
import { EuiFormRow, EuiSelect, EuiSelectProps } from '@elastic/eui';
import { get } from 'lodash';
import { useFormContext } from 'react-hook-form';

export interface MedSelectProps extends EuiSelectProps {
  label?: string;
  width?: string;
}

export const MedSelect: React.FC<MedSelectProps> = ({ label, ...selectProps }) => {
  const { register, errors } = useFormContext();
  const { name } = selectProps;

  return (
    <EuiFormRow
      className={selectProps.className}
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
      fullWidth={selectProps.fullWidth}
      style={{ width: selectProps.width }}
    >
      <EuiSelect style={selectProps.style} inputRef={register} isInvalid={!!get(errors, name)} {...selectProps} />
    </EuiFormRow>
  );
};
