import React, { useState, useMemo, useContext, Fragment, useEffect } from 'react';
import moment from 'moment';
import {
  EuiButton,
  EuiFlexGroup,
  EuiFlexItem,
  EuiPageContent,
  EuiPageContentBody,
  EuiSpacer,
  EuiBadge,
  EuiLink,
  EuiCard,
  EuiTabs,
  EuiTab,
  EuiDescriptionList,
} from '@elastic/eui';
import { AdminAppContext, AdminPageProps, withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { buildEventsList } from '@/common/utils/audit_trail/builder';
import { dashDateToSlashDate } from '@/common/utils/dates/dates';
import { Patient, ServiceRequest } from '@/common/types';
import { PatientDataRow } from './PatientSearchBar';
import AuditingList, { AuditEvent } from '@/common/components/AuditingList/AuditingList';
import styled from 'styled-components';
import { googleMapsUrl } from '@/common/utils/addresses/addresses';
import { CreateVisitModal } from '../scheduling/CreateVisitModal';
import { Program } from '@/common/types/index';
import { PatientInfoTab } from './PatientInfoTab';
import { PatientNotesTab } from './PatientNotesTab';
import { PatientVisitsCalendarTab } from './PatientVisitsCalendarTab';
import { withFieldLayout } from '@/field/components/FieldLayout/FieldLayout';

import queryString from 'query-string';

interface PatientPageProps extends AdminPageProps {
  patient: Patient;
  statuses?: string[];
  paper_trail?: Array<[string, Array<string>]>;
  patient_programs?: Program[];
  service_requests?: ServiceRequest[];
  dropdownOptions?: any;
  all_programs?: any;
  current_user?: any;
  added_visit_id?: string;
}

interface FormattedPatient extends Patient {
  fullName: string;
  dischargeDate: moment.Moment;
  phoneNumbers: string;
  genderSexPronouns: string;
  emergencyContact: string;
}

// export this for testing
// @TODO - probably better to move this function to a helper file
export const getPatientAge = (date) => {
  const age = Math.floor(moment(new Date()).diff(moment(date, 'YYYY-MM-DD'), 'years', true));
  return `${age} years old`;
};

// @TODO - probably better to move this function to a helper file
export const formatPatient = (patient: Patient): FormattedPatient => {
  // @TODO - to be updated once we know for sure that patient will have this field (the design assumes it's available)
  const gender = patient.gender;
  const status = patient.status;

  const { phone_number_type, secondary_phone_number_type } = patient;

  const phoneNumberType = phone_number_type ? `(${phone_number_type})` : '';
  const secondaryPhoneNumberType = secondary_phone_number_type ? `(${secondary_phone_number_type})` : '';

  return {
    ...patient,
    gender,
    status,
    fullName:
      patient.display_name ||
      `${patient.first_name} ${patient.middle_initial ? patient.middle_initial : ''} ${patient.last_name}`,
    // @TODO: get actual dischargeDate from EHR
    dischargeDate: moment(new Date('March 30, 2021 12:00:00')),
    phoneNumbers:
      patient.display_phone_number &&
      `Primary: ${patient.display_phone_number} ${phoneNumberType}${
        patient.secondary_phone_number
          ? ', Secondary: ' + patient.display_secondary_phone_number + ' ' + secondaryPhoneNumberType
          : ''
      }`,
    genderSexPronouns: `${patient.sex || ''} ${gender ? `identifying as ${gender}` : ''} ${
      patient.preferred_pronouns ? `using ${patient.preferred_pronouns}` : ''
    }`,
    emergencyContact: `${patient.emergency_contact_name || ''} ${
      patient.emergency_contact_phone_number ? `, ${patient.emergency_contact_phone_number}` : ''
    }`,
  };
};

// @TODO - probably better to move this function to a helper file / service
const patientData = (patient: Patient, sanitizedPatient: FormattedPatient): Array<PatientDataRow> => {
  const { custom_field_responses, programs } = patient;
  const patientTable = [
    {
      name: 'ID #',
      value: patient.id,
    },
    {
      name: 'Patient Id (MRN, Member Id)',
      value: patient.medical_record_number || '',
    },
    {
      name: 'Name',
      value: sanitizedPatient.fullName || '',
    },
    {
      name: 'Date of Birth',
      value: dashDateToSlashDate(sanitizedPatient.date_of_birth),
    },
    {
      name: 'Address',
      value: patient.address ? (
        <EuiLink href={googleMapsUrl(patient.address)} external target="_blank">
          {patient.address?.display_name}
        </EuiLink>
      ) : (
        ''
      ),
    },
    {
      name: 'Email Address',
      value: patient.user?.email || '',
    },
    {
      name: 'Phone Number(s)',
      render: (
        <>
          {sanitizedPatient.phoneNumbers}
          {patient.consent_to_text ? (
            <EuiBadge color="secondary" style={{ margin: '0 0.4em' }}>
              SMS Consent
            </EuiBadge>
          ) : null}
        </>
      ),
    },
    {
      name: 'Demand Partner',
      value: patient.demand_partner?.name,
    },
  ];

  if (custom_field_responses) {
    custom_field_responses.map((response) => {
      patientTable.push({
        name: response?.demand_partner_custom_field?.display_name,
        render: <div data-test-id="tags">{response.value}</div>,
      });
    });
  }

  if (programs) {
    patientTable.push({
      name: 'Program',
      render: <div data-test-id="tags">{programs.map((p) => p.name).join(', ')}</div>,
    });
  }

  return patientTable;
};

const CustomEuiDescriptionList = styled(EuiDescriptionList)`
  &&&& {
    .euiDescriptionList__title,
    .euiDescriptionList__description {
      margin-top: 5px;
    }
  }
`;

export const PatientShowPageComponent: React.FC<PatientPageProps> = ({
  patient,
  dropdownOptions,
  paper_trail,
  patient_programs,
  all_programs,
  current_user,
  added_visit_id,
  service_requests = [],
}) => {
  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const { service_ids } = currentParams;

  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const sanitizedPatient: FormattedPatient = useMemo(() => formatPatient(patient), []);
  const items: Array<PatientDataRow> = useMemo(() => (current_user ? patientData(patient, sanitizedPatient) : []), [
    JSON.stringify(patient),
    current_user?.id,
  ]);

  const events: Array<AuditEvent> = useMemo(() => buildEventsList(paper_trail, patient.admin_notes), [
    patient,
    paper_trail,
  ]);
  const [isEditingPatient, setIsEditingPatient] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const closeModal = () => {
    setIsModalOpen(false);
  };

  const setIsEditingPatientAndTab = (isEditing = true) => {
    setIsEditingPatient(isEditing);
    setSelectedTabId('info--id');
  };
  const tabs = [
    {
      id: 'visits--id',
      name: 'Visits',
      content: (
        <Fragment>
          <EuiSpacer />
          <PatientVisitsCalendarTab patient={patient} current_user={current_user} added_visit_id={added_visit_id} />
        </Fragment>
      ),
    },
    {
      id: 'info--id',
      name: 'Info',
      content: (
        <Fragment>
          <EuiSpacer />
          <PatientInfoTab
            patient={patient}
            address={patient.address}
            demand_partners={dropdownOptions?.demand_partners}
            sexes={dropdownOptions?.sexes}
            genders={dropdownOptions?.genders}
            languages={dropdownOptions?.languages}
            programs={patient_programs}
            user={patient.user}
            all_programs={all_programs}
            isEditingPatient={isEditingPatient}
            setIsEditingPatient={setIsEditingPatientAndTab}
            useFieldLayout={isFieldAccount()}
          />
        </Fragment>
      ),
    },
  ];

  if (!isFieldAccount()) {
    tabs.push({
      id: 'notes--id',
      name: 'Notes',
      content: (
        <Fragment>
          <PatientNotesTab patient={patient} current_user={current_user} />
        </Fragment>
      ),
    });
    tabs.push({
      id: 'activity--id',
      name: 'Activity',
      content: (
        <Fragment>
          <EuiSpacer />
          <AuditingList patient={patient} events={events} color="#223a73" />
        </Fragment>
      ),
    });
  }

  const patientFirstColumn = [
    {
      title: `${getPatientAge(sanitizedPatient.date_of_birth)}${patient.sex !== 'Unknown' ? `, ${patient.sex}` : ''}`,
      description: '',
    },
    {
      title: 'Birthdate',
      description: sanitizedPatient.date_of_birth,
    },
    {
      title: 'Phone Number',
      description: sanitizedPatient.phoneNumbers,
    },
  ];

  const patientSecondColumn = [
    {
      title: 'Address',
      description: patient.address ? (
        <EuiLink style={{ position: 'absolute' }} href={googleMapsUrl(patient.address)} external target="_blank">
          {patient.address?.display_name}
        </EuiLink>
      ) : (
        ''
      ),
    },
    {
      title: 'Preferred Language',
      description: patient.preferred_language,
    },
    {
      title: 'Email',
      description: patient.contact_email,
    },
  ];

  const patientThirdColumn = () => {
    const thirdColumn = [
      {
        title: <EuiSpacer size="l" />,
        description: '',
      },
      {
        title: 'Programs',
        description: <div data-test-id="tags">{patient_programs?.map((p) => p.name).join(', ')}</div>,
      },
      {
        title: 'Demand Partner',
        description: patient.demand_partner?.name,
      },
    ];

    return isFieldAccount() ? thirdColumn.slice(0, 2) : thirdColumn;
  };

  const [selectedTabId, setSelectedTabId] = useState('visits--id');
  const selectedTabContent = useMemo(() => {
    return tabs.find((obj) => obj.id === selectedTabId)?.content;
  }, [selectedTabId, current_user, isEditingPatient]);

  const serviceRequestOptions = useMemo(
    () =>
      service_requests.map(({ id, program_id, service_id }) => ({
        id,
        programId: program_id,
        serviceId: service_id,
      })),
    [],
  );

  const onSelectedTabChanged = (id: string) => {
    setSelectedTabId(id);
  };

  useEffect(() => {
    if (service_ids) {
      setIsModalOpen(true);
    }
  }, []);

  return (
    <div>
      {isModalOpen && (
        <CreateVisitModal
          current_user={current_user}
          programs={patient_programs}
          closeModal={closeModal}
          patient={patient}
          serviceRequests={serviceRequestOptions}
        />
      )}
      <>
        <EuiCard
          style={{ marginBottom: '24px', border: 'none', position: 'relative' }}
          className={'PatientInfoSummary'}
          textAlign="left"
          title={
            <EuiFlexGroup justifyContent={'spaceBetween'}>
              <EuiFlexItem>{sanitizedPatient.fullName}</EuiFlexItem>
              <EuiFlexItem grow={false}>
                <EuiButton
                  onClick={() => setIsEditingPatientAndTab()}
                  color="primary"
                  size="m"
                  style={{ fontFamily: 'Raleway' }}
                  iconType="documentEdit"
                >
                  Edit Patient
                </EuiButton>
              </EuiFlexItem>
            </EuiFlexGroup>
          }
        >
          <EuiFlexGroup>
            <EuiFlexItem>
              <CustomEuiDescriptionList type="column" listItems={patientFirstColumn} />
            </EuiFlexItem>
            <EuiFlexItem>
              <CustomEuiDescriptionList type="column" listItems={patientSecondColumn} />
            </EuiFlexItem>
            <EuiFlexItem>
              <CustomEuiDescriptionList type="column" listItems={patientThirdColumn()} />
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiCard>
        <EuiPageContent
          style={{
            backgroundColor: '#ffffff',
            fontFamily: 'Raleway',
            position: 'relative',
            border: 'none',
          }}
        >
          <EuiPageContentBody>
            <EuiFlexGroup justifyContent="spaceBetween">
              <EuiFlexItem grow={false}>
                <EuiTabs style={{ width: '480px' }}>
                  {tabs.map((tab) => {
                    return (
                      <EuiTab
                        style={{ width: '120px' }}
                        key={tab.id}
                        onClick={() => onSelectedTabChanged(tab.id)}
                        isSelected={tab.id === selectedTabId}
                      >
                        {tab.name}
                      </EuiTab>
                    );
                  })}
                </EuiTabs>
              </EuiFlexItem>
              <EuiFlexItem grow={false}>
                <EuiButton
                  style={{ width: 'max-content', fontSize: '14px', fontWeight: 500 }}
                  iconType="plusInCircle"
                  onClick={() => setIsModalOpen(true)}
                  color="primary"
                  fill
                >
                  New Visit
                </EuiButton>
              </EuiFlexItem>
            </EuiFlexGroup>
            <div>{selectedTabContent}</div>
          </EuiPageContentBody>
        </EuiPageContent>
      </>
    </div>
  );
};

export const FieldSchedulerPatientShowPage = withFieldLayout(PatientShowPageComponent);
export const PatientShowPage = withAdminLayout(PatientShowPageComponent);
