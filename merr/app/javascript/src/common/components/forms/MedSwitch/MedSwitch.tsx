import React from 'react';
import { EuiSwitch, EuiSwitchProps } from '@elastic/eui';
import { Controller, useFormContext } from 'react-hook-form';
import { SetRequired } from 'type-fest';

export type MedSwitchProps = SetRequired<Omit<EuiSwitchProps, 'checked' | 'onChange'>, 'name'>;

export const MedSwitch: React.FC<MedSwitchProps> = ({ name, ...switchProps }) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      render={({ onChange, value }) => {
        return (
          <EuiSwitch
            checked={!!value}
            onChange={(e) => {
              onChange(e.target.checked);
            }}
            {...switchProps}
          />
        );
      }}
    />
  );
};
