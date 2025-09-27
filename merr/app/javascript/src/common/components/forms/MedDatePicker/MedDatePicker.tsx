import { EuiDatePicker, EuiDatePickerProps, EuiFormRow } from '@elastic/eui';
import React, { useCallback } from 'react';
import { Controller, useFormContext, UseFormMethods } from 'react-hook-form';
import { get } from 'lodash';
import moment from 'moment-timezone';

import { formatUtc } from '@/common/utils/dates/dates';

export interface MedDatePickerProps extends Omit<EuiDatePickerProps, 'utcOffset'> {
  maxWidth?: string;
  label?: string;
  form?: UseFormMethods<any>;
}

export const MedDatePicker: React.FC<MedDatePickerProps> = ({
  maxWidth = '400px',
  name,
  label,
  form,
  ...datePickerProps
}) => {
  const { control, errors } = form || useFormContext();
  const { showTimeSelect } = datePickerProps;

  // If not showing time select or there's no timezone applied, return only dates
  const dateOnly = !showTimeSelect;

  // EuiDatePicker expects a moment date
  // These transforms make sure we only deal with strings outside of it
  const inboundTransform = (date: string): moment.Moment => (date ? moment(date) : null);

  // On change, return the date in UTC format
  const outboundTransform = useCallback((date: moment.Moment): string => {
    if (!date) {
      return null;
    }

    return dateOnly ? formatUtc(date).substr(0, 10) : formatUtc(date);
  }, []);

  return (
    <EuiFormRow style={{ maxWidth }} label={label} isInvalid={!!get(errors, name)} error={get(errors, name)?.message}>
      <Controller
        name={name}
        control={control}
        render={({ onChange, value }) => (
          <EuiDatePicker
            name={name}
            selected={inboundTransform(value)}
            onChange={(date) => onChange(outboundTransform(date))}
            {...datePickerProps}
          />
        )}
      />
    </EuiFormRow>
  );
};
