import React, { useState } from 'react';
import { PatientProspect } from '@/common/types';
import {
  EuiHorizontalRule,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiTitle,
  EuiPageContent,
  EuiPageContentHeader,
  EuiPageContentBody,
  EuiSpacer,
  EuiText,
  EuiFieldSearch,
  EuiLink,
  formatDate,
} from '@elastic/eui';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { PaginationFooter } from '@/common/components/PaginationFooter/PaginationFooter';
import { dischargeDatesField, PatientProspectTable } from './PatientProspectTable';
import { MedFlyout } from '@/common/components/MedFlyout/MedFlyout';
import { SHORT_DATE_FORMAT } from '@/common/utils/dates/dates';
import { PaginationParams, usePagination } from '@/common/hooks/usePagination/usePagination';
import { DeleteIconForm } from '@/common/components/DeleteIconForm/DeleteIconForm';
import { InvertedTable, DataRow } from '@/admin/components/InvertedTable/InvertedTable';
import { admin_patient_prospect_path } from '@/common/routes';

type Props = AdminPageProps & {
  patient_prospects: PatientProspect[];
  pagination: PaginationParams;
  query?: string;
};

const onSearch = (text) => {
  window.location.href = `/admin/patient_prospects?s=${encodeURIComponent(text)}`;
};

export const PatientProspectIndexPage: React.FC<Props> = ({ layout_props, pagination, patient_prospects, query }) => {
  const [activeProspect, setActiveProspect] = useState<PatientProspect | null>(null);
  const paginationProps = usePagination(pagination);

  const {
    medical_record_number,
    diagnosis,
    notes,
    preferred_language,
    zipcode,
    created_by,
    demand_partner,
    created_at,
  } = activeProspect || {};

  const prospectData: DataRow[] = [
    {
      name: 'Demand Partner',
      render: demand_partner ? (
        <EuiLink href={`/admin/demand_partners/${demand_partner.id}`}>{demand_partner.name}</EuiLink>
      ) : null,
    },
    {
      name: 'Created By',
      value: typeof created_by === 'string' ? created_by : created_by?.display_name,
    },
    {
      name: 'Date Added',
      value: formatDate(created_at, SHORT_DATE_FORMAT),
    },
    {
      name: 'Diagnosis',
      value: diagnosis?.join(', '),
    },
    {
      name: 'Discharge Dates',
      value: activeProspect ? dischargeDatesField(activeProspect) : null,
    },
    {
      name: 'Notes',
      value: notes,
    },
    {
      name: 'Preferred Language',
      value: preferred_language,
    },
    {
      name: 'ZIP Code',
      value: zipcode,
    },
    {
      name: '',
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
  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Prospects</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>All Prospects</h2>
          </EuiTitle>
        </EuiPageContentHeader>
        <EuiFieldSearch
          placeholder="Search..."
          isClearable={true}
          defaultValue={query}
          fullWidth={true}
          onSearch={onSearch}
        />
        <EuiSpacer size="s" />
        <EuiText size="s" color="subdued">
          {'Search Patient ID.'}
        </EuiText>
        <EuiSpacer size="m" />
        <EuiHorizontalRule margin="s" />
        <EuiSpacer size="m" />

        <EuiPageContentBody>
          <PatientProspectTable data={patient_prospects} onClick={(prospect) => setActiveProspect(prospect)} />

          <PaginationFooter {...paginationProps} />
        </EuiPageContentBody>
      </EuiPageContent>

      <MedFlyout
        title={`Patient ID #: ${medical_record_number}`}
        show={!!activeProspect}
        onClose={() => setActiveProspect(null)}
      >
        <EuiText>
          <InvertedTable items={prospectData} />
        </EuiText>
      </MedFlyout>
    </AdminLayout>
  );
};
