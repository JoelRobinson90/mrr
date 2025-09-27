import React, { FC, useState, useEffect } from 'react';
import { PlusOneWarning } from '../PlusOneWarning';
import { AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedComboBox, MedHiddenField, MedTextArea } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useSyncForm } from '@/common/hooks/useSyncForm/useSyncForm';
import {
  admin_alayacare_edit_visit_path,
  admin_patient_path,
  admin_visit_path,
  field_patient_path,
  field_visit_path,
  admin_patient_visits_path,
  field_patient_visits_path,
} from '@/common/routes';
import {
  EuiBadge,
  EuiDescriptionList,
  EuiDescriptionListDescription,
  EuiDescriptionListTitle,
  EuiFlexItem,
  EuiSpacer,
} from '@elastic/eui';
import { useGetVisitQuery } from '@/generated/graphql';
import { yupResolver } from '@hookform/resolvers';
import * as yup from 'yup';
import { formatDate, LONG_DATE_FORMAT, TIME_FORMAT, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { Patient, Service, VisitType } from '@/common/types';
import { find, first, sumBy } from 'lodash';
import moment from 'moment';

interface EditVisitPartialProps extends AdminPageProps {
  visit: any;
  program_services: Service[];
  patient: Patient;
  visit_types: VisitType[];
  current_user: any;
}

export const editVisitSchema = yup.object().shape({
  service_ids: yup.array().of(yup.string()),
});

export const EditVisitPartial: FC<EditVisitPartialProps> = ({
  visit,
  patient,
  program_services = [],
  visit_types,
  current_user,
}) => {
  const [editOnlyInstructions, setEditOnlyInstructions] = useState(true);
  const [plusOneWarningUnderstood, setPlusOneWarningUnderstood] = useState(false);
  const { refetch: refetchVisitData, data: visitDataFetched, loading: loadingVisitData } = useGetVisitQuery({
    variables: {
      visit_id: visit?.external_id || '',
    },
    fetchPolicy: 'no-cache',
  });
  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const calculateUrl = () => {
    if (!isFieldAccount()) {
      if (visit.local) {
        return admin_visit_path(visit.local_visit_id);
      }
      return admin_alayacare_edit_visit_path({ alayacare_visit_id: visit.alayacare_visit_id });
    } else {
      // External accounts should never have AC-centric visits
      return field_visit_path(visit.local_visit_id);
    }
  };

  const visitDuration = moment(visit.cx_end).diff(moment(visit.cx_start), 'minutes');

  const onFormSubmit = (value) => {
    const { visit: formVisit } = value;
    const { service_ids, visit_type_id } = formVisit;

    const link = isFieldAccount() ? field_patient_visits_path : admin_patient_visits_path;

    const currentVisitType = find(visit_types, (vt) => vt.id?.toString() === visit_type_id);

    const newServices = services.filter((s) => service_ids.includes(s.id));
    const newServicesDuration = sumBy(newServices, 'duration');

    const url = link(patient.id, {
      program_id: visit.program_id,
      visit_type_id: visit_type_id,
      duration: parseInt(`${currentVisitType.duration}`, 10) + newServicesDuration,
      service_ids: `${service_ids.map((id) => `service_${id}`).join(',')}`,
      external_id: visit.external_id,
      limit_arrival_window: true,
      ignore_existing_visit_conflicts: true,
    });

    window.location.assign(url);
  };

  const { syncFormProps, form } = useSyncForm({
    url: calculateUrl(),
    method: 'put',
    formId: 'editVisitForm',
    formOptions: {
      defaultValues: {
        alayacare_visit_id: visit?.alayacare_visit_id,
        patient_id: patient?.id,
        visit: {
          service_ids: visit?.services?.map((s) => s.id),
          service_instructions: visit?.service_instructions,
          visit_type_id: visit?.visit_type_id,
          visit_type_combobox: visit?.visit_type_id,
        },
      },
      resolver: yupResolver(editVisitSchema),
    },
    onFormSubmit: editOnlyInstructions ? null : onFormSubmit,
  });

  useEffect(() => {
    const { service_ids, visit_type_id } = form.watch()?.visit;
    const checkServices = JSON.stringify(service_ids) === JSON.stringify(visit?.services?.map((s) => s.id));
    const checkVisitType = visit_type_id?.toString() === visit?.visit_type_id?.toString();

    if ((checkVisitType && checkServices) || visit?.status === 'completed') {
      setEditOnlyInstructions(true);
    } else if (editOnlyInstructions) {
      setEditOnlyInstructions(false);
    }
  }, [form.watch]);

  const timezone = patient?.address?.timezone;

  const visitTypeOptions = visit_types?.map((v) => {
    return {
      value: v.id,
      label: v.name,
    };
  });

  const { watch, setValue } = form;

  const [isServicesBlank, setIsServicesBlank] = useState('');

  const serviceIds: Array<string> = watch('visit.service_ids');

  useEffect(() => {
    serviceIds?.length === 0 ? setIsServicesBlank('true') : setIsServicesBlank('false');
  }, [serviceIds]);

  // NOTE: doing this hidden field logic because MedComboBox is sending an array for single options.
  const currentVisitTypeComboValue: Array<string> = form.watch('visit.visit_type_combobox');
  // currentVisitTypeId is holding the visit_type_id value so this way is sent as an id and not an array.
  const currentVisitTypeId = first(currentVisitTypeComboValue) || visit?.visit_type_id;

  const cVisitTypeId = watch('visit_type_id');
  const visitTypeServices = visit_types?.find(
    (vt) => vt.id.toString() == cVisitTypeId || vt.id.toString() == currentVisitTypeId,
  )?.services;
  let services = [];

  if (visitTypeServices) {
    services = program_services ? [...program_services, ...visitTypeServices] : [...visitTypeServices];
  }

  const servicesOptions = services?.map((s) => {
    return { value: s.id, label: s.name };
  });
  const renderForm = (
    <SyncForm {...syncFormProps}>
      <MedHiddenField name="patient_id" readOnly hidden />
      <MedHiddenField name="alayacare_visit_id" readOnly hidden />

      <EuiDescriptionList type="column">
        <EuiDescriptionListTitle style={{ width: '40%' }}>Field Provider</EuiDescriptionListTitle>
        <EuiDescriptionListDescription style={{ width: '60%', textAlign: 'right' }}>{`${
          visit.field_provider?.first_name || ''
        }
          ${visit.field_provider?.last_name || ''}`}</EuiDescriptionListDescription>
        <EuiDescriptionListTitle style={{ width: '30%' }}>Date</EuiDescriptionListTitle>
        <EuiDescriptionListDescription style={{ width: '70%', textAlign: 'right' }}>{`${formatDate(
          visit.start_time,
          LONG_DATE_FORMAT,
          timezone,
        )}`}</EuiDescriptionListDescription>
        <EuiDescriptionListTitle style={{ width: '30%' }}>Time</EuiDescriptionListTitle>
        <EuiDescriptionListDescription style={{ width: '70%', textAlign: 'right' }}>{`${formatDate(
          visit.cx_start,
          TIME_FORMAT,
          timezone,
        )} - ${formatDate(visit.cx_end, TIME_FORMAT_WITH_ZONE, timezone)}`}</EuiDescriptionListDescription>

        {visit.canceled && (
          <>
            <EuiDescriptionListTitle>Status</EuiDescriptionListTitle>
            <EuiDescriptionListDescription>
              <EuiBadge color={'default'}>cancelled</EuiBadge>
            </EuiDescriptionListDescription>
          </>
        )}
      </EuiDescriptionList>

      <EuiSpacer size="l" />
      {visit?.local && (
        <>
          {/* TODO: enable back when we can actually sync services to AC */}
          <MedComboBox
            width="100%"
            name="visit.service_ids"
            label="Services"
            options={servicesOptions}
            placeholder="Select a service from the list"
          />
          <MedHiddenField name="visit.no_services" value={isServicesBlank} />

          <EuiSpacer size="l" />
          {!!visitTypeOptions?.length && (
            <MedComboBox
              width="100%"
              name="visit.visit_type_combobox"
              label="Visit Type"
              options={visitTypeOptions}
              placeholder="Select visit type from the list"
              singleSelection={{ asPlainText: true }}
            />
          )}
          <MedHiddenField name="visit.visit_type_id" value={currentVisitTypeId} />
        </>
      )}
      <EuiSpacer size="l" />
      <MedTextArea
        name="visit.service_instructions"
        label="Service Instructions"
        fullWidth
        placeholder="Parking instructions, door code, anything patient wants field provider to know prior to the visit."
      />
    </SyncForm>
  );

  return (
    <>
      {visit?.visit_group_id && (
        <PlusOneWarning
          visitGroup={visitDataFetched?.getVisit?.visitGroup}
          plusOneWarningUnderstood={plusOneWarningUnderstood}
          setPlusOneWarningUnderstood={setPlusOneWarningUnderstood}
          current_user={current_user}
          verb={'edit'}
          currentPatientId={patient.id}
        />
      )}
      {(!visitDataFetched?.getVisit?.visitGroup || plusOneWarningUnderstood === true) && (
        <EuiFlexItem grow={false}>{renderForm}</EuiFlexItem>
      )}
    </>
  );
};
