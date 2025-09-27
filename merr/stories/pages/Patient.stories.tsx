import React from 'react';
import { Meta } from '@storybook/react';
import { PatientShowPage } from '@/admin/pages/patients/PatientShowPage';

export default {
  title: 'Components/Admin/PatientShow',
  component: PatientShowPage,
} as Meta;

export function PatientShowLayout() {
  const patient = {
    id: 1,
    first_name: 'Ronna',
    last_name: 'Quitzon',
    gender: 'Male',
    date_of_birth: '1978-11-23',
    medical_record_number: '329247596',
    phone_number: '(354) 855-7775',
    location: 'North Shonnaview, NE',
    partner: 'partner-1',
    status: 'Needing Services',
    provider_org: {
      name: 'Millenium Physician Group',
    },
  };

  const layoutProps = {
    breadcrumbs: [
      {
        text: 'Patients',
        href: '#',
      },
      {
        text: `${patient.first_name} ${patient.last_name}`,
        href: '#',
      },
    ],
  };

  const STATUSES = [
    'Care Complete',
    'Created',
    'Referred: Cancelled',
    'Referred: Needs Scheduling',
    'Scheduled with Issue',
    'Referred: Cancelled',
    'Referred: Scheduled',
  ];

  return <PatientShowPage patient={patient} layout_props={layoutProps} statuses={STATUSES} />;
}
