import React from 'react';
import { EuiRadioGroup, EuiRadioGroupProps } from '@elastic/eui';
import { Controller, useFormContext } from 'react-hook-form';

export type MedRadioGroupProps = Omit<EuiRadioGroupProps, 'onChange'>;

export const MedRadioGroup: React.FC<MedRadioGroupProps> = ({ name, ...radioProps }) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      render={({ onChange, value }) => (
        // TODO: investigate issue with omitting onChange optional and
        // it complaining about the legend prop
        // @ts-ignore
        <EuiRadioGroup idSelected={value} onChange={(id) => onChange(id)} options={[]} {...radioProps} />
      )}
    />
  );
};
