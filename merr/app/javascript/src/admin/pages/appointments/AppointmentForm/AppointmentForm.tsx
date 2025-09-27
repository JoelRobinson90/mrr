import { Appointment } from '@/common/types';
import { EuiButton, EuiButtonEmpty, EuiFlexGroup, EuiFlexItem, EuiHorizontalRule, EuiSpacer } from '@elastic/eui';
import {
  MedComboBox,
  MedMaskedInput,
  MedSwitch,
  MedTextArea,
  MedTextField,
  InlineFormGroup,
  InlineField,
  NestedFields,
  LeftField,
  RightField,
} from '@/common/components/forms';
import React, { useEffect, useMemo, useState } from 'react';
import { map } from 'lodash';
import { useFieldArray, useFormContext } from 'react-hook-form';

import moment from 'moment-timezone';
import styled from 'styled-components';

import { MedHiddenField } from '@/common/components/forms/MedHiddenField/MedHiddenField';
import { MedDatePicker } from '@/common/components/forms/MedDatePicker/MedDatePicker';
import { DB_DATE_FORMAT, formatDate, formatUtc, TIME_ZONE_ONLY } from '@/common/utils/dates/dates';
import { useEffectSkipFirst } from '@/common/hooks/useEffectSkipFirst/useEffectSkipFirst';

interface AppointmentFormProps {
  appointment: Appointment;
  cancel?: string;
  available_tags: string[];
  showActions?: boolean;
}

const HiddenMedComboBox = styled(MedComboBox)`
  display: none !important;
`;

export const AppointmentForm: React.FC<AppointmentFormProps> = ({
  appointment,
  cancel,
  available_tags,
  showActions = true,
}) => {
  const { setValue, watch } = useFormContext();
  const { tag_list, address, start_time, end_time } = appointment;

  const block_size = 60;

  const timezone = address?.timezone;

  // These are UI-only date and time pickers that run in the browser time zone
  // _appointment_start_time and _appointment_end_time are used for time only
  // When fields are updated, we manually splice together the date field and the relevant time field
  // and convert it to the appointment time zone to get the resulting UTC timestamp
  const selectedStartDate = watch('_appointment_date');
  const selectedStartTime = watch('_appointment_start_time');
  const selectedEndTime = watch('_appointment_end_time');

  const findCurrentDuration = (start: string, end: string): number => {
    if (start && end) {
      const duration = moment.duration(moment(end).diff(moment(start)));
      return duration.asMinutes();
    } else {
      return block_size;
    }
  };

  // Track difference between the two time dropdowns, initialize to DB values
  const [currentDuration, setCurrentDuration] = useState(findCurrentDuration(start_time, end_time));

  // On mount, populate UI fields in browser timezone
  useEffect(() => {
    setValue('_appointment_date', timezone && moment(start_time).tz(timezone).format(DB_DATE_FORMAT));
    if (start_time) {
      const momentStartTime = moment(start_time).tz(timezone);
      setValue(
        '_appointment_start_time',
        formatUtc(moment().set('h', momentStartTime.hour()).set('m', momentStartTime.minute())),
      );
    }
    if (end_time) {
      const momentEndTime = moment(end_time).tz(timezone);
      setValue(
        '_appointment_end_time',
        formatUtc(moment().set('h', momentEndTime.hour()).set('m', momentEndTime.minute())),
      );
    }
  }, []);

  const timezoneLabel = useMemo(() => formatDate(selectedStartDate, TIME_ZONE_ONLY, timezone), [
    selectedStartTime,
    timezone,
  ]);

  // Join _appointment_date and _appointment_start_time and save to appointment.start_time
  // Also update _appointment_end_time to persist duration
  useEffectSkipFirst(() => {
    if (selectedStartDate && selectedStartTime) {
      const momentStartDate = moment(selectedStartDate);
      const momentStartTime = moment(selectedStartTime);
      const newSavedStartTime = moment()
        .tz(timezone)
        .set('y', momentStartDate.year())
        .set('dayOfYear', momentStartDate.dayOfYear())
        .set('h', momentStartTime.hour())
        .set('m', momentStartTime.minute())
        .set('s', 0);

      setValue('appointment.start_time', formatUtc(newSavedStartTime));
      setValue('_appointment_end_time', formatUtc(momentStartTime.clone().add(currentDuration, 'm')));
    }
  }, [selectedStartDate, selectedStartTime]);

  // Join _appointment_date and _appointment_end_time and save to appointment.end_time
  useEffectSkipFirst(() => {
    if (selectedStartDate && selectedEndTime) {
      const momentStartDate = moment(selectedStartDate);
      const momentEndTime = moment(selectedEndTime);
      const newSavedEndTime = moment()
        .tz(timezone)
        .set('y', momentStartDate.year())
        .set('dayOfYear', momentStartDate.dayOfYear())
        .set('h', momentEndTime.hour())
        .set('m', momentEndTime.minute())
        .set('s', 0);

      setValue('appointment.end_time', formatUtc(newSavedEndTime));
    }
  }, [selectedStartDate, selectedEndTime]);

  // When end time changes, update currentDuration
  useEffect(() => {
    if (selectedStartTime && selectedEndTime) {
      setCurrentDuration(findCurrentDuration(selectedStartTime, selectedEndTime));
    }
  }, [selectedEndTime]);

  // To prevent error if object already tagged with element not in the list.
  const tagOptions = useMemo(() => {
    const allTags = available_tags.concat(tag_list);
    return map(allTags, (tag) => ({ value: tag, label: tag }));
  }, []);

  return (
    <>
      <MedTextField name="appointment.patient_id" hidden />
      <InlineFormGroup>
        <LeftField>Address</LeftField>
        <RightField>
          <InlineField data-test-id="addressLineOne" minWidth="200px">
            <MedTextField prepend="Line 1" name="appointment.address_attributes.address_line_one" fullWidth />
          </InlineField>
          <InlineField minWidth="200px">
            <MedTextField prepend="Line 2" name="appointment.address_attributes.address_line_two" fullWidth />
          </InlineField>
          <InlineField minWidth="200px">
            <MedTextField prepend="City" name="appointment.address_attributes.city" fullWidth />
          </InlineField>
          <InlineField minWidth="200px">
            <MedTextField prepend="State" name="appointment.address_attributes.state" fullWidth />
          </InlineField>
          <InlineField minWidth="200px">
            <MedTextField prepend="Zip" name="appointment.address_attributes.zipcode" fullWidth />
          </InlineField>
          <MedTextField name="appointment.address_attributes.latitude" hidden />
          <MedTextField name="appointment.address_attributes.longitude" hidden />
          <MedTextField name="appointment.address_attributes.id" hidden />
        </RightField>
      </InlineFormGroup>
      {timezone && (
        <>
          <InlineFormGroup>
            <LeftField>Date</LeftField>
            <RightField>
              <MedDatePicker name="_appointment_date" />
            </RightField>
          </InlineFormGroup>
          <InlineFormGroup>
            <LeftField>Start Time ({timezoneLabel})</LeftField>
            <RightField>
              <MedDatePicker
                showTimeSelect
                showTimeSelectOnly
                name="_appointment_start_time"
                dateFormat="hh:mm a"
                timeFormat="hh:mm a"
                injectTimes={[
                  moment().hours(0).minutes(1),
                  moment().hours(0).minutes(5),
                  moment().hours(23).minutes(59),
                ]}
              />
              <MedHiddenField name="appointment.start_time" />
            </RightField>
          </InlineFormGroup>
          <InlineFormGroup>
            <LeftField>End Time ({timezoneLabel})</LeftField>
            <RightField>
              <MedDatePicker
                showTimeSelect
                showTimeSelectOnly
                name="_appointment_end_time"
                dateFormat="hh:mm a"
                timeFormat="hh:mm a"
                injectTimes={[
                  moment().hours(0).minutes(1),
                  moment().hours(0).minutes(5),
                  moment().hours(23).minutes(59),
                ]}
              />
              <MedHiddenField name="appointment.end_time" />
            </RightField>
          </InlineFormGroup>
          <InlineFormGroup>
            <LeftField>Base Duration</LeftField>
            <RightField>
              <MedTextField name="appointment.base_duration" />
            </RightField>
            <p data-testid="HRA">(Not counting extra recipients or HRA survey)</p>
          </InlineFormGroup>
        </>
      )}

      <InlineFormGroup>
        <LeftField>Extra Vaccine Recipients</LeftField>
        <EuiFlexItem>
          <ExtraVaccineRecipientFields />
        </EuiFlexItem>
      </InlineFormGroup>
      <InlineFormGroup>
        <LeftField>Tags</LeftField>
        <RightField>
          <MedComboBox width="100%" name="appointment.tag_list" options={tagOptions} placeholder="Select tags" />
        </RightField>
      </InlineFormGroup>
      <InlineFormGroup>
        <LeftField margin=" 15px auto auto">Dispatch Notes</LeftField>
        <RightField>
          <MedTextArea fullWidth width="100%" name="appointment.dispatch_notes" />
        </RightField>
      </InlineFormGroup>
      {showActions ? (
        <EuiFlexGroup style={{ backgroundColor: '#f5f7fa', padding: '1rem', marginTop: '0' }}>
          <EuiFlexItem>
            <EuiButtonEmpty style={{ maxWidth: '153px' }} onClick={() => (location.href = cancel)} type="button">
              Cancel
            </EuiButtonEmpty>
          </EuiFlexItem>
          <EuiFlexItem style={{ alignItems: 'flex-end' }}>
            <EuiButton style={{ backgroundColor: '#00b38f', maxWidth: '153px', border: 'none' }} fill type="submit">
              Save
            </EuiButton>
          </EuiFlexItem>
        </EuiFlexGroup>
      ) : null}
    </>
  );
};

const ExtraVaccineRecipientFields: React.FC = () => {
  const { control } = useFormContext();

  const { fields, append } = useFieldArray({
    control,
    name: 'appointment[extra_vaccine_recipients_attributes]',
    keyName: 'key',
  });

  return (
    <>
      {fields.map((item, index) => {
        const prefix = `appointment.extra_vaccine_recipients_attributes[${index}]`;

        return (
          <NestedFields key={item.key}>
            {index > 0 ? <EuiHorizontalRule margin="xs" /> : null}
            <MedHiddenField name={`${prefix}[id]`} />
            <InlineField>
              <MedTextField prepend="Name" name={`${prefix}.name`} />
            </InlineField>
            <InlineField>
              <MedTextField prepend="Phone Number" name={`${prefix}.phone_number`} />
            </InlineField>
            <InlineField>
              <MedMaskedInput prepend="Date of Birth" mask="99/99/9999" name={`${prefix}.date_of_birth`} />
            </InlineField>
            <InlineField maxWidth={'153px'}>
              <MedSwitch label="Confirmed" name={`${prefix}.confirmed`} />
            </InlineField>
            <InlineField maxWidth={'153px'}>
              <MedSwitch label="SMS Consent" name={`${prefix}.consent_to_text`} />
            </InlineField>
            <InlineField maxWidth={'153px'}>
              <MedSwitch label="Archive" name={`${prefix}.deleted`} />
            </InlineField>
          </NestedFields>
        );
      })}
      {fields.length > 0 && <EuiSpacer size="m" />}
      <div style={{ display: 'block' }}>
        <EuiButton size="s" onClick={() => append({})} iconType="plus">
          Add Extra Vaccine Recipient
        </EuiButton>
      </div>
    </>
  );
};
