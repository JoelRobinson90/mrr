import React, { Fragment, useContext, useMemo, useState } from 'react';
import {
  EuiButton,
  EuiFilePicker,
  EuiFlexGrid,
  EuiFlexGroup,
  EuiFlexItem,
  EuiFormRow,
  EuiHorizontalRule,
  EuiHorizontalRuleProps,
  EuiIcon,
  EuiLink,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiPanel,
  EuiSpacer,
  EuiText,
  EuiTitle,
  EuiFlyout,
} from '@elastic/eui';
import { map, uniq } from 'lodash';
import { useForm, Controller, useFormContext } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers';
import * as yup from 'yup';
import styled from 'styled-components';
import moment from 'moment';
import { AdminAppContext, AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { Appointment, FieldProvider } from '@/common/types';
import { buildEventsList } from '@/common/utils/audit_trail/builder';
import AuditingList, { AuditEvent } from '@/common/components/AuditingList/AuditingList';
import { MedStatusDropdown } from '@/common/components/MedStatusDropdown/MedStatusDropdown';
import { formatDate, TIME_FORMAT, appointmentDisplayDateTime } from '@/common/utils/dates/dates';
import { formatPatient, getPatientAge } from '@/admin/pages/patients/PatientShowPage';
import { MedTextArea, MedTextField, MedComboBox } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';
import { formattedAddressComponents, googleMapsUrl } from '@/common/utils/addresses/addresses';
import { RemotePartial } from '@/common/components/RemotePartial/RemotePartial';
import {
  admin_appointment_path,
  admin_notes_admin_appointment_path,
  admin_patient_path,
  edit_partial_admin_appointment_path,
  fetch_clinical_summary_admin_appointment_path,
  tags_admin_appointment_path,
} from '@/common/routes';
import { FieldProviderAssigner } from '@/common/components/FieldProviderAssigner/FieldProviderAssigner';
import { AdditionalDataCollection } from './AdditionalDataCollection';

const DownloadFileStyled = styled(EuiPanel)`
  width: max-content;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  text-align: center;
  margin-bottom: 8px;
  color: #a1aab8;
  font-weight: 700;
  padding: 15px 22px;
  small p {
    margin-top: 25px !important;
  }
`;

// @TODO: once colors are moved to theme provider this should be a prop.theme variable
const LinkStyled = styled(EuiLink)`
  color: #223a73;
  font-weight: 500;
`;

const TextStyled = styled.p`
  line-height: 1.5;
`;

const ButtonSubmitStyled = styled(EuiButton)`
  position: absolute;
  bottom: 18px;
  right: 25px;
  background-color: #223e7d !important;
`;

const InputHidden = styled(MedTextField)`
  display: none;
`;

const DescriptionTitleStyled = styled(EuiFlexItem)`
  && {
    text-align: left;
    flex-grow: 3;
    @media (min-width: 768px) {
      text-align: right;
    }
    @media (min-width: 1200px) {
      flex-grow: 1;
    }
  }
`;

const horizontalRuleMargin: EuiHorizontalRuleProps['margin'] = 'm';

interface AppointmentShowPageProps extends AdminPageProps {
  appointment: Appointment;
  available_tags: string[];
  statuses: string[];
  paper_trail: Array<[string, Array<string>]>;
  field_providers: FieldProvider[];
}
interface PatientDescriptionProps {
  title: React.ReactNode;
  description: React.ReactNode;
}

const formatDateOfBirth = (data) => moment(data).format('MM-DD-YYYY');

export const noteSchema = yup.object().shape({
  admin_note: yup.object().shape({
    content: yup.string().label('Content').required(),
  }),
});

export const PatientDescription: React.FC<PatientDescriptionProps> = ({ title, description }) => {
  return (
    <>
      <EuiFlexGrid>
        <DescriptionTitleStyled grow={1}>
          <EuiText style={{ fontWeight: 'bold' }}>{title}</EuiText>
        </DescriptionTitleStyled>
        <EuiFlexItem grow={6}>
          <EuiText>{description}</EuiText>
        </EuiFlexItem>
      </EuiFlexGrid>
      <EuiSpacer size="m" />
    </>
  );
};

export const VisitResultForm: React.FC<{ name: string }> = ({ name }) => {
  const { control } = useFormContext();
  return (
    <>
      <Controller
        name={name}
        control={control}
        render={({ onChange }) => {
          return (
            <EuiFilePicker
              style={{ width: '100%' }}
              type="file"
              accept=".pdf"
              id="a12sd3"
              initialPromptText="Select or drag and drop file"
              onChange={(file) => onChange(file)}
              display={'default'}
              aria-label="Use aria labels when no actual label is in use"
            />
          );
        }}
      />
    </>
  );
};

const AppointmentFileSection: React.FC<{ appointment: Appointment }> = ({ appointment }) => {
  const fileForm = useForm({
    defaultValues: {
      appointment: {
        visit_results: {},
      },
    },
  });

  // @TODO: NOT IMPLEMENTED should load from appointment files.
  // const files = [
  //   {
  //     key: 1,
  //     title: 'PDF',
  //     download: 'file1.pdf',
  //   },
  //   {
  //     key: 2,
  //     title: 'CSV',
  //     download: 'file2.csv',
  //   },
  // ];
  const files = [];
  return (
    <>
      <EuiFlexGroup>
        {map(files, (file) => (
          <EuiFlexItem
            key={file.name}
            grow={false}
            style={{ alignItems: 'center', cursor: 'pointer' }}
            onClick={() => console.log('Download')}
          >
            <DownloadFileStyled>
              <small>
                <EuiIcon type="exportAction" />
                <p style={{ width: '100%', marginTop: '15px' }}>{file.name}</p>
              </small>
            </DownloadFileStyled>
            {file.download}
          </EuiFlexItem>
        ))}
      </EuiFlexGroup>
      <EuiSpacer size="xl" />
      <SyncForm form={fileForm} url={`/admin/appointments/${appointment.id}/visit_results`} method="post" multipart>
        <EuiFlexGroup style={{ alignItems: 'flex-start' }}>
          <EuiFlexItem grow={2}>
            <VisitResultForm name="appointment.visit_results" />
            <EuiSpacer />
          </EuiFlexItem>
          <EuiFlexItem>
            <div>
              <EuiButton type="submit">Upload</EuiButton>
            </div>
          </EuiFlexItem>
        </EuiFlexGroup>
      </SyncForm>
    </>
  );
};

const StatusIcon: React.FC<{ label: string; value: boolean }> = ({ label, value }) => {
  const color = value ? 'success' : 'danger';
  const iconType = value ? 'check' : 'cross';

  return (
    <EuiFlexGroup>
      <EuiFlexItem grow={false}>{label}:</EuiFlexItem>
      <EuiFlexItem grow={false}>
        <EuiIcon type={iconType} size="m" color={color} />
      </EuiFlexItem>
    </EuiFlexGroup>
  );
};

export const AppointmentShowPage: React.FC<AppointmentShowPageProps> = ({
  layout_props,
  appointment,
  paper_trail,
  statuses,
  available_tags,
  field_providers,
}) => {
  const { currentUser } = useContext(AdminAppContext);

  const [flyoutPath, setFlyoutPath] = useState<string | null>(null);
  const {
    patient,
    address,
    field_provider,
    status,
    tag_list,
    extra_vaccine_recipients,
    id,
    updated_at,
    admin_notes,
    duration,
    base_duration,
    dispatch_notes,
    hra_survey_status,
    available_surveys,
    covid_vaccination,
  } = appointment;
  const { user, demand_partner, sex, preferred_pronouns } = patient || {};
  const sanitizedPatient = formatPatient(patient);
  const admin_note = {
    creator_id: currentUser.id,
    content: '',
  };

  const defaultAppointmentStatus = {
    status,
  };

  const fieldProviderName = field_provider ? `${field_provider?.display_name || field_provider.email}` : '(Unassigned)';
  const long = parseFloat(address?.longitude);
  const lat = parseFloat(address?.latitude);
  const coordinates = [long, lat];
  const geoJson = {
    type: 'FeatureCollection',
    features: [
      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates,
        },
      },
    ],
  };

  const events: Array<AuditEvent> = useMemo(() => buildEventsList(paper_trail, admin_notes), [
    appointment,
    paper_trail,
  ]);

  const form = useForm({
    defaultValues: {
      admin_note,
    },
    resolver: yupResolver(noteSchema),
  });

  const tagForm = useForm({
    defaultValues: {
      appointment: {
        tag_list,
      },
    },
  });

  const fetchClinicalSummary = () => {
    submitSyncForm(fetch_clinical_summary_admin_appointment_path(id), 'post');
  };

  // To prevent error if object already tagged with element not in the list.
  const allTags = uniq([...available_tags, ...(tag_list || [])]);
  const tagOptions = map(allTags, (tag) => ({ value: tag, label: tag }));

  const openEditFlyout = () => setFlyoutPath(edit_partial_admin_appointment_path(id));
  const closeEditFlyout = () => setFlyoutPath(null);

  let flyout;
  if (flyoutPath) {
    flyout = (
      <EuiFlyout onClose={() => setFlyoutPath(null)} hideCloseButton>
        <RemotePartial
          path={flyoutPath}
          partialProps={{
            onClose: closeEditFlyout,
            redirectPath: admin_appointment_path(id),
          }}
        />
      </EuiFlyout>
    );
  }

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <span>Appointment</span>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          <EuiButton onClick={openEditFlyout} style={{ border: 'solid 1px #d3dae6', background: 'white' }} color="text">
            Edit Appointment
          </EuiButton>
        </EuiPageHeaderSection>
      </EuiPageHeader>
      <EuiPanel>
        <EuiPageHeader>
          <EuiPageHeaderSection>
            <EuiTitle size="l">
              <span>{appointmentDisplayDateTime(appointment)}</span>
            </EuiTitle>
          </EuiPageHeaderSection>
          <EuiPageHeaderSection>
            <MedStatusDropdown
              status={status}
              statuses={statuses}
              url={admin_appointment_path(id)}
              defaultValues={defaultAppointmentStatus}
              name="appointment.status"
            />
          </EuiPageHeaderSection>
        </EuiPageHeader>
        <EuiTitle size="xs">
          <span style={{ fontWeight: 'normal' }}>
            {updated_at &&
              `Last updated ${formatDate(updated_at, 'MMMM Do, YYYY')} at ${formatDate(updated_at, TIME_FORMAT)}`}
          </span>
        </EuiTitle>
        <EuiSpacer size="m" />

        <SyncForm form={tagForm} url={tags_admin_appointment_path(id)} method="post">
          <EuiFlexGroup gutterSize="l" style={{ maxWidth: 550 }}>
            <EuiFlexItem data-testid="tags">
              <MedComboBox
                className="tag_list"
                name="appointment.tag_list"
                options={tagOptions}
                placeholder="Select tags"
              />
            </EuiFlexItem>
            <EuiFlexItem grow={false}>
              <EuiFormRow>
                <EuiButton type="submit">Save Tags</EuiButton>
              </EuiFormRow>
            </EuiFlexItem>
          </EuiFlexGroup>
        </SyncForm>
        <EuiHorizontalRule
          margin={horizontalRuleMargin}
          style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
        />
        <EuiSpacer size="m" />
        <EuiFlexGroup>
          <EuiFlexItem grow={6}>
            <PatientDescription
              title={<b>Patient</b>}
              description={
                <TextStyled>
                  <a href={admin_patient_path(patient.id)}>{`${patient.first_name} ${patient.last_name}`}</a>
                  <br /> {sex} {preferred_pronouns && `(${preferred_pronouns})`}{' '}
                  {getPatientAge(sanitizedPatient.date_of_birth)} ({formatDateOfBirth(sanitizedPatient.date_of_birth)})
                  {patient.preferred_language ? (
                    <>
                      <br />
                      Preferred Language: {patient.preferred_language}
                    </>
                  ) : null}
                </TextStyled>
              }
            />
            <PatientDescription
              title={<b>Email</b>}
              description={<LinkStyled>{user?.email || 'Unknown'}</LinkStyled>}
            />
            <PatientDescription
              title={<b>Primary #</b>}
              description={
                patient.phone_number ? (
                  <LinkStyled href={`tel:${patient.phone_number}`}>{patient.display_phone_number}</LinkStyled>
                ) : null
              }
            />
            <PatientDescription
              title={<b>Secondary #</b>}
              description={
                patient.secondary_phone_number ? (
                  <LinkStyled href={`tel:${patient.secondary_phone_number}`}>
                    {patient.display_secondary_phone_number}
                  </LinkStyled>
                ) : null
              }
            />
            <PatientDescription
              title={<b>Address</b>}
              description={
                address ? (
                  <LinkStyled href={googleMapsUrl(address)} target="_blank">
                    {formattedAddressComponents(address).join(', ')}
                  </LinkStyled>
                ) : null
              }
            />
            <PatientDescription title={<b>County</b>} description={<p>{address?.county}</p>} />
            <PatientDescription
              title={<b>Em. Contact</b>}
              description={
                <p>
                  {patient?.emergency_contact_name} <LinkStyled>{patient?.emergency_contact_phone_number}</LinkStyled>
                </p>
              }
            />
            {/* <PatientDescription title={<b>Diagnosis</b>} description={<p>Diabetes, Congestive Heart Failure</p>} /> */}
            <PatientDescription
              title={<b>Referrer</b>}
              description={
                <TextStyled>
                  {demand_partner?.name}
                  {/* <br /> Dr. Faith Evans,{' '} */}
                  {/* <LinkStyled>(232) 234 - 2323, faith.evans@hospital.com</LinkStyled> */}
                </TextStyled>
              }
            />
            <PatientDescription title={<b>Base Duration</b>} description={<TextStyled>{base_duration}</TextStyled>} />
            <PatientDescription title={<b>Duration</b>} description={<TextStyled>{duration}</TextStyled>} />
            <PatientDescription
              title={<b>Extra Vaccine Recipients</b>}
              description={
                <div style={{ width: '100%' }}>
                  {extra_vaccine_recipients?.length
                    ? extra_vaccine_recipients.map((evr, index) => (
                        <Fragment key={evr.id}>
                          {index > 0 ? <EuiHorizontalRule margin="xs" /> : null}
                          <EuiFlexGroup style={{ width: '100%' }}>
                            <EuiFlexItem style={{ minWidth: '33%' }}>
                              Recipient Name: {evr.name}
                              <br />
                              <StatusIcon label={'Confirmed'} value={evr.confirmed} />
                            </EuiFlexItem>
                            <EuiFlexItem style={{ minWidth: '33%' }}>
                              Phone Number: {evr.phone_number}
                              <br />
                              <StatusIcon label={'Consent to text'} value={evr.consent_to_text} />
                            </EuiFlexItem>
                            <EuiFlexItem style={{ minWidth: '33%' }}>
                              Date of Birth: {evr.date_of_birth}
                              <br />
                              <StatusIcon label={'Complete'} value={evr.complete} />
                            </EuiFlexItem>
                          </EuiFlexGroup>
                        </Fragment>
                      ))
                    : 'N/a'}
                </div>
              }
            />
            <PatientDescription title={<b>Dispatch Notes</b>} description={<TextStyled>{dispatch_notes}</TextStyled>} />
            <PatientDescription
              title={<b>Visit Results</b>}
              description={<AppointmentFileSection appointment={appointment} />}
            />
            <PatientDescription
              title={<b>Additional Data Collection</b>}
              description={<AdditionalDataCollection surveys={available_surveys} hraStatus={hra_survey_status} />}
            />
            {covid_vaccination && (
              <PatientDescription
                title={<b>Covid Vaccine Type</b>}
                description={<TextStyled>{covid_vaccination.vaccine_type}</TextStyled>}
              />
            )}
          </EuiFlexItem>
          <EuiFlexItem grow={2}>
            <EuiPanel grow={false}>
              <EuiText style={{ textAlign: 'center', fontWeight: 'bold' }}>
                <p>Assigned Field Provider</p>
              </EuiText>
              <EuiFlexGroup gutterSize="s">
                <EuiFlexItem data-test-id="selectFieldProvider" style={{ justifyContent: 'center' }}>
                  <FieldProviderAssigner
                    submitUrl={admin_appointment_path(id)}
                    fieldName="appointment.field_provider_id"
                    formMethod="put"
                    fieldProviders={field_providers}
                    selectedFieldProvider={field_provider}
                    submitButtonLabel="Assign Field Provider"
                  />
                  <p>
                    <small>{field_provider?.provider_level}</small>
                  </p>
                </EuiFlexItem>
              </EuiFlexGroup>
              <EuiSpacer size="l" />
              <EuiFlexGroup direction="column">
                <EuiFlexItem grow={false}>
                  {fieldProviderName && (
                    <TextStyled>
                      {field_provider?.phone && (
                        <>
                          Phone:{' '}
                          <LinkStyled href={`tel:${field_provider?.phone}`} target="_blank">
                            {field_provider?.phone}
                          </LinkStyled>
                        </>
                      )}
                    </TextStyled>
                  )}
                </EuiFlexItem>
              </EuiFlexGroup>
            </EuiPanel>
            <EuiSpacer size="m" />
            <EuiSpacer size="m" />
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiPanel>
      <EuiSpacer size="xl" />
      <EuiFlexGroup gutterSize="none">
        <EuiFlexItem grow={4}>
          <EuiHorizontalRule
            margin={horizontalRuleMargin}
            style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
          />
        </EuiFlexItem>
        <EuiFlexItem grow={4}>
          <EuiHorizontalRule
            margin={horizontalRuleMargin}
            style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
          />
        </EuiFlexItem>
      </EuiFlexGroup>
      <EuiSpacer size="xl" />
      <EuiFlexGroup gutterSize="l">
        <EuiFlexItem grow={1}>
          <EuiTitle size="xxs">
            <span style={{ textAlign: 'end' }}>
              Appointment <br /> Notes
            </span>
          </EuiTitle>
        </EuiFlexItem>
        <EuiFlexItem grow={10} style={{ position: 'relative' }}>
          <SyncForm form={form} url={admin_notes_admin_appointment_path(id)} method="post">
            <InputHidden name="admin_note.creator_id" />
            <MedTextArea
              name="admin_note.content"
              style={{ backgroundColor: 'white' }}
              fullWidth
              placeholder="These are some notes related to the appointment for the operations team."
            />
            <ButtonSubmitStyled type="submit" fill>
              Submit
            </ButtonSubmitStyled>
          </SyncForm>
        </EuiFlexItem>
      </EuiFlexGroup>
      <EuiSpacer size="l" />
      <EuiHorizontalRule
        margin={horizontalRuleMargin}
        style={{ width: '100%', height: '1px', backgroundColor: '#d3dae6' }}
      />
      <EuiSpacer size="l" />
      <AuditingList patient={patient} events={events} color="#223a73" />
      {flyout}
    </AdminLayout>
  );
};
