import React from 'react';
import { DemandPartner, Patient } from '@/common/types';
import {
  EuiHorizontalRule,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiTitle,
  EuiButton,
  EuiPageContent,
  EuiPageContentHeader,
  EuiPageContentBody,
  EuiSpacer,
  EuiText,
} from '@elastic/eui';
import { withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { withFieldLayout } from '@/field/components/FieldLayout/FieldLayout';
import { PaginationFooter } from '@/common/components/PaginationFooter/PaginationFooter';
import { PatientsTable } from '@/admin/components/PatientsTable/PatientsTable';
import {
  admin_patients_path,
  field_patients_path,
  admin_patient_path,
  new_admin_patient_path,
  field_patient_path,
} from '@/common/routes';
import { SearchWithFilters } from '../../components/filters/SearchWithFilters/SearchWithFilters';
import { usePagination, PaginationParams } from '@/common/hooks/usePagination/usePagination';

interface PatientIndexPageProps {
  patients: Patient[];
  pagination: PaginationParams;
  query: string;
  demand_partners: DemandPartner[];
  filters: {
    demand_partner: string;
  };
  current_user?: any;
}

export const PatientIndexPageComponent: React.FC<PatientIndexPageProps> = ({
  pagination,
  patients,
  query,
  demand_partners,
  filters,
  current_user,
}) => {
  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const isExternalAccount = () => {
    return current_user?.account_type === 'ExternalAccount';
  };

  const onSearch = (text) => {
    if (isFieldAccount()) {
      window.location.href = field_patients_path({ s: text });
    } else {
      window.location.href = admin_patients_path({ s: text });
    }
  };

  const onRowClick = ({ id }: Patient) => {
    if (isFieldAccount()) {
      window.location.href = field_patient_path(id);
    } else {
      window.location.href = admin_patient_path(id);
    }
  };

  const paginationProps = usePagination(pagination);

  const options = () => {
    if (isExternalAccount()) {
      return null;
    } else {
      const options = {
        demand_partners: demand_partners.map((d) => ({
          label: d.name,
          value: `${d.id}`,
        })),
      };

      return options;
    }
  };

  return (
    <>
      {current_user && !isFieldAccount() && (
        <EuiPageHeader>
          <EuiPageHeaderSection>
            <EuiTitle size="l">
              <h1>Patients</h1>
            </EuiTitle>
          </EuiPageHeaderSection>
          <EuiPageHeaderSection>
            <EuiButton onClick={() => (window.location.href = new_admin_patient_path())} fill color="ghost" size="m">
              New Patient
            </EuiButton>
          </EuiPageHeaderSection>
        </EuiPageHeader>
      )}

      <EuiPageContent style={{ position: 'relative' }}>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>All Patients</h2>
          </EuiTitle>
        </EuiPageContentHeader>
        <SearchWithFilters options={options()} filters={filters} query={query} onSearch={onSearch} />
        <EuiSpacer size="s" />
        <EuiText size="s" color="subdued">
          {`Search prefixes of: ${
            !isFieldAccount() ? 'address, ' : ''
          }first name, last name, Patient ID, DOB (must be YYYY-MM-DD), or phone (Ten digits, numbers only e.g. 5551112222).`}
        </EuiText>
        <EuiSpacer size="m" />
        <EuiHorizontalRule margin="s" />
        <EuiSpacer size="m" />

        <EuiPageContentBody>
          <PatientsTable data={patients} onClick={onRowClick} useExternalAcctLayout={isExternalAccount()} />

          <PaginationFooter {...paginationProps} />
        </EuiPageContentBody>
      </EuiPageContent>
    </>
  );
};

export const FieldSchedulerPatientIndexPage = withFieldLayout(PatientIndexPageComponent);
export const PatientIndexPage = withAdminLayout(PatientIndexPageComponent);
