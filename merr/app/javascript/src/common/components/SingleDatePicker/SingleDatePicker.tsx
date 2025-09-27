import { EuiFlexGroup, EuiFlexItem, EuiIcon, EuiTitle, EuiFormRow, EuiDatePicker } from '@elastic/eui';
import React from 'react';
import moment from 'moment';

type Props = {
  selectedDate?: string;
  onChange?: (date: moment.Moment) => void;
  headerText?: string;
};

const changeDay = (specificDay, modifiedDays) => {
  const date = moment(specificDay).add(modifiedDays, 'days');
  return date;
};

export const SingleDatePicker: React.FC<Props> = ({ selectedDate, onChange, headerText }) => {
  return (
    <EuiTitle>
      <EuiFlexGroup
        responsive={false}
        alignItems={'center'}
        justifyContent={'spaceBetween'}
        direction={'row'}
        wrap={false}
      >
        <EuiFlexItem grow={false} style={{ maxWidth: 50, cursor: 'pointer' }}>
          <EuiIcon
            onClick={() => {
              const date = changeDay(selectedDate, -1);
              onChange(date);
            }}
            type="sortLeft"
            size="xl"
          />
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <h3 style={{ textAlign: 'center' }}>{headerText}</h3>
          <EuiFormRow data-test-id="datePickerTest">
            <EuiDatePicker
              className="datePicker"
              selected={moment(selectedDate)}
              onChange={(date) => {
                const differentDay = date.format('DD') !== moment(selectedDate).format('DD');
                if (differentDay) {
                  onChange(date);
                }
              }}
            />
          </EuiFormRow>
        </EuiFlexItem>
        <EuiFlexItem grow={false} style={{ maxWidth: 50, cursor: 'pointer' }}>
          <EuiIcon
            onClick={() => {
              const newDate = changeDay(selectedDate, 1);
              onChange(newDate);
            }}
            type="sortRight"
            size="xl"
            data-test-id="next"
          />
        </EuiFlexItem>
      </EuiFlexGroup>
    </EuiTitle>
  );
};
