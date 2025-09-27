import { EuiDatePicker, EuiDatePickerProps, EuiFormRow } from '@elastic/eui';
import React, { useCallback } from 'react';
import { Controller, useFormContext, UseFormMethods } from 'react-hook-form';
import { get, isArray } from 'lodash';
import moment from 'moment';

export interface MedDateTimePickerProps extends EuiDatePickerProps {
  label?: string;
  form?: UseFormMethods<any>;
}

const DEFAULT_DATE_FORMAT = 'MM/DD/YYYY HH:mm';

export const MedDateTimePicker: React.FC<MedDateTimePickerProps> = ({
  name,
  label,
  form,
  dateFormat = DEFAULT_DATE_FORMAT,
  ...datePickerProps
}) => {
  const { control, errors } = form || useFormContext();

  // TODO: allow null to pass in and out of EuiDatePicker
  const inboundTransform = useCallback((date: string): moment.Moment => moment(date, dateFormat), [dateFormat]);

  const outboundTransform = useCallback(
    (date: moment.Moment): string => date.format(isArray(dateFormat) ? dateFormat[0] : dateFormat),
    [dateFormat],
  );

  return (
    <EuiFormRow label={label} isInvalid={!!get(errors, name)} error={get(errors, name)?.message}>
      <Controller
        name={name}
        control={control}
        render={({ onChange, value }) => (
          <EuiDatePicker
            showTimeSelect
            selected={inboundTransform(value)}
            onChange={(date) => onChange(outboundTransform(date))}
            dateFormat={dateFormat}
            {...datePickerProps}
          />
        )}
      />
    </EuiFormRow>
  );
};
