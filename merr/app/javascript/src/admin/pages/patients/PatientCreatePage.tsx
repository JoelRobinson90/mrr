import React from 'react';
import { Address, DemandPartner, Patient, Program, Pharmacy, User } from '@/common/types';
import {
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiTitle,
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiSpacer,
  EuiText,
  EuiTextColor,
  EuiHorizontalRule,
  EuiHorizontalRuleProps,
} from '@elastic/eui';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { PatientForm } from './PatientForm/PatientForm';
import { formatPatient, getPatientAge } from './PatientShowPage';

interface PatientCreatePageProps extends AdminPageProps {
  patient: Patient;
  pharmacies: Array<Pharmacy>;
  user: User;
  address: Address;
  demand_partners: Array<DemandPartner>;
  sexes: Array<string>;
  genders: Array<string>;
  pronouns: Array<string>;
  languages: Array<string>;
  races?: Array<string>;
  ethnicities?: Array<string>;
  phone_types?: Array<string>;
  programs?: Array<Program>;
}

const horizontalRuleMargin: EuiHorizontalRuleProps['margin'] = 'm';

export const PatientCreatePage: React.FC<PatientCreatePageProps> = ({
  layout_props,
  patient,
  demand_partners,
  genders,
  sexes,
  languages,
  programs,
}) => {
  const sanitizedPatient = formatPatient(patient);
  const { id } = patient;

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Patients</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>{id ? `${sanitizedPatient.fullName}` : 'New Patient'}</h2>
          </EuiTitle>
        </EuiPageContentHeader>

        <EuiPageContentBody>
          {id ? (
            <EuiText>
              <p>
                <EuiTextColor color="subdued">
                  {sanitizedPatient.genderSexPronouns} • {getPatientAge(sanitizedPatient.date_of_birth)} (
                  {sanitizedPatient.date_of_birth}) • #{sanitizedPatient.medical_record_number}
                </EuiTextColor>
              </p>
            </EuiText>
          ) : null}
          <EuiHorizontalRule
            margin={horizontalRuleMargin}
            style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
          />
          <EuiSpacer />

          <PatientForm
            demandPartners={demand_partners}
            sexes={sexes}
            genders={genders}
            languages={languages}
            isNew={id === null}
            all_programs={programs}
            patient={patient}
            setIsEditingPatient={() => (location.href = '/admin/patients')}
          />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
