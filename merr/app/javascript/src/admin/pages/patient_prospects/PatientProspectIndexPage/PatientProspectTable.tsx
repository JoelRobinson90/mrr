import React from 'react';
import { EuiLink, EuiIconTip } from '@elastic/eui';
import moment from 'moment';
import { MedTable, MedTableProps } from '@/common/components/MedTable/MedTable';
import { DemandPartner, PatientProspect } from '@/common/types';
import { formatDate, SHORT_DATE_FORMAT } from '@/common/utils/dates/dates';
import { DeleteIconForm } from '@/common/components/DeleteIconForm/DeleteIconForm';
import { admin_patient_prospect_path } from '@/common/routes';
import { RIGHT_ALIGNMENT } from '@elastic/eui/lib/services';

export const dischargeDatesField = ({ discharge_start, discharge_end }: PatientProspect): string | null => {
  if (!discharge_start && !discharge_end) {
    return null;
  }

  const startDate = discharge_start ? formatDate(discharge_start, SHORT_DATE_FORMAT) : 'N/A';
  const endDate = discharge_end ? formatDate(discharge_end, SHORT_DATE_FORMAT) : 'N/A';

  let numDaysLabel = '';
  if (discharge_start && discharge_end) {
    const numDays = moment(discharge_end).diff(moment(discharge_start), 'days');
    const dayLabel = numDays === 1 ? 'day' : 'days';
    numDaysLabel = ` (${numDays} ${dayLabel})`;
  }

  return `${startDate} - ${endDate}${numDaysLabel}`;
};

const columns: MedTableProps<PatientProspect>['columns'] = [
  {
    field: 'created_at',
    name: 'Date Added',
    render: (created_at: string) => formatDate(created_at, SHORT_DATE_FORMAT),
  },
  {
    field: 'medical_record_number',
    name: 'Name',
    render: (mrn: string) => (mrn ? `Patient ID #: ${mrn}` : null),
  },
  {
    name: 'Submitted By',
    render: ({ created_by }: PatientProspect) =>
      typeof created_by === 'string' ? created_by : created_by?.display_name,
  },
  {
    field: 'demand_partner',
    name: 'Partner',
    render: (demand_partner: DemandPartner) =>
      demand_partner ? (
        <EuiLink href={`/admin/demand_partners/${demand_partner.id}`}>{demand_partner.name}</EuiLink>
      ) : null,
  },
  {
    name: 'Discharge Dates',
    render: (prospect: PatientProspect) => dischargeDatesField(prospect),
  },
  {
    field: 'notes',
    name: 'Notes',
    render: (notes: string) =>
      notes ? <EuiIconTip content={notes} type="list" position="left" data-testid="notes-icon" /> : null,
  },
  {
    name: '',
    align: RIGHT_ALIGNMENT,
    render: ({ id, medical_record_number }) => {
      return (
        <DeleteIconForm
          id={id}
          confirmationMessage={`Are you sure you want to delete prospective patient - ${medical_record_number} ?`}
          url={admin_patient_prospect_path(id)}
        />
      );
    },
  },
];

interface PatientProspectTableProps {
  data: PatientProspect[];
  onClick?: (patientProspect: PatientProspect) => void;
}

export const PatientProspectTable: React.FC<PatientProspectTableProps> = ({ data, onClick }) => {
  const getRowProps = (item: PatientProspect) => ({ onClick: onClick ? () => onClick(item) : null });

  return <MedTable items={data} columns={columns} rowProps={getRowProps} />;
};
