import React from 'react';
import { useFormContext } from 'react-hook-form';

export type MedHiddenFieldProps = React.DetailedHTMLProps<
  React.InputHTMLAttributes<HTMLInputElement>,
  HTMLInputElement
>;

export const MedHiddenField: React.FC<MedHiddenFieldProps> = (props) => {
  const { register } = useFormContext();

  return <input type="hidden" ref={register} {...props} />;
};
