import { EuiComboBox, EuiComboBoxOptionOption, EuiFormRow, EuiComboBoxSingleSelectionShape } from '@elastic/eui';
import React from 'react';
import { Controller, useFormContext } from 'react-hook-form';
import { compact, get } from 'lodash';

export interface MedComboBoxProps {
  name: string;
  options: EuiComboBoxOptionOption[];
  label?: string;
  placeholder?: string;
  width?: string;
  fullWidth?: boolean;
  singleSelection?: EuiComboBoxSingleSelectionShape;
  className?: string;
  disabled?: boolean;
  isClearable?: boolean;
  hidden?: boolean;
  externalOnchange?: (
    onChange: (...event: any[]) => void,
    options: EuiComboBoxOptionOption<string | number | string[]>[],
  ) => void;
}

export const MedComboBox: React.FC<MedComboBoxProps> = ({
  name,
  options,
  label,
  placeholder,
  width,
  fullWidth,
  singleSelection,
  className,
  disabled,
  isClearable = true,
  hidden,
  externalOnchange,
}) => {
  const { control, errors } = useFormContext();

  return (
    <EuiFormRow
      data-test-id={name}
      data-testid={name}
      className={className}
      style={{ width }}
      label={label}
      isInvalid={!!get(errors, name)}
      error={get(errors, name)?.message}
    >
      <Controller
        name={name}
        control={control}
        defaultValue={[]}
        render={({ onChange, value }) => {
          let selected = value || [];
          if (typeof value === 'number') {
            selected = [value];
          }
          return (
            <EuiComboBox
              hidden={hidden}
              placeholder={placeholder}
              options={options}
              isDisabled={disabled}
              style={{ width }}
              onChange={(options) => {
                if (externalOnchange) externalOnchange(onChange, options);
                else onChange(options.map((o) => o.value));
              }}
              selectedOptions={compact(selected.map((val) => options.find((o) => o.value === val)))}
              isClearable={isClearable}
              fullWidth={fullWidth}
              singleSelection={singleSelection}
            />
          );
        }}
      />
    </EuiFormRow>
  );
};
