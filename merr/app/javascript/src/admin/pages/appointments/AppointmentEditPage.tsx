import React from 'react';
import { EuiPageHeader, EuiPageHeaderSection, EuiPanel, EuiTitle, EuiButton, EuiSpacer, EuiHealth } from '@elastic/eui';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { Appointment } from '@/common/types';
import { STATUS_COLOR_MAP } from '@/common/components/MedBadge/MedBadge';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';
import { formatDate, TIME_FORMAT } from '@/common/utils/dates/dates';
import { AppointmentForm } from './AppointmentForm/AppointmentForm';
import { MedSuperSelect } from '@/common/components/forms/MedSuperSelect/MedSuperSelect';

interface AppointmentEditPageProps extends AdminPageProps {
  appointment: Appointment;
  statuses: string[];
  available_tags: string[];
}

export const AppointmentEditPage: React.FC<AppointmentEditPageProps> = ({
  layout_props,
  appointment,
  statuses,
  available_tags,
}) => {
  const {
    patient,
    address,
    start_time,
    status,
    dispatch_notes,
    base_duration,
    tag_list,
    extra_vaccine_recipients,
    id,
    updated_at,
  } = appointment;

  const appointmentStatuses = statuses.map((value) => ({
    value,
    inputDisplay: (
      <EuiHealth color={STATUS_COLOR_MAP[value]} style={{ lineHeight: 'inherit' }}>
        {value}
      </EuiHealth>
    ),
  }));

  const defaultValues = {
    status,
    start_time,
    address_attributes: { ...address },
    patient_id: patient.id,
    dispatch_notes,
    tag_list,
    base_duration: base_duration || 30,
    extra_vaccine_recipients_attributes: extra_vaccine_recipients,
  };

  const form = useForm({
    defaultValues: {
      appointment: defaultValues,
    },
  });

  const targetUrl = id ? `/admin/appointments/${id}` : `/admin/appointments`;
  const targetMethod = id ? 'put' : 'post';

  const fromPatientView = location.search.includes('patient_id') && patient.id;
  const cancelUrl = fromPatientView ? `/admin/patients/${patient.id}` : `/admin/appointments/${id}`;

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <span>Appointment</span>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          <EuiButton style={{ border: 'solid 1px #d3dae6' }} color="text" href={cancelUrl}>
            Cancel
          </EuiButton>
        </EuiPageHeaderSection>
      </EuiPageHeader>
      <EuiPanel>
        <SyncForm form={form} url={targetUrl} method={targetMethod}>
          <EuiPageHeader>
            <EuiPageHeaderSection>
              <EuiTitle size="l">
                <span>
                  {start_time
                    ? `${patient.first_name} ${patient.last_name} ${formatDate(start_time, 'l')}`
                    : `${patient.first_name} ${patient.last_name}`}
                </span>
              </EuiTitle>
            </EuiPageHeaderSection>
            <EuiPageHeaderSection>
              <MedSuperSelect name="appointment.status" width="200px" options={appointmentStatuses} />
            </EuiPageHeaderSection>
          </EuiPageHeader>
          <EuiSpacer size="m" />
          <EuiTitle size="xs">
            <span style={{ fontWeight: 'normal' }}>
              {updated_at &&
                `Last updated ${formatDate(updated_at, 'MMMM Do, YYYY')} at ${formatDate(updated_at, TIME_FORMAT)}`}
            </span>
          </EuiTitle>
          <EuiSpacer size="m" />

          <AppointmentForm cancel={targetUrl} appointment={appointment} available_tags={available_tags} />
        </SyncForm>
      </EuiPanel>
    </AdminLayout>
  );
};
