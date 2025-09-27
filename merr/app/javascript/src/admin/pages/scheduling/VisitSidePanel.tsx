import React, { useState, useEffect, FC, useMemo } from 'react';
import {
  EuiButton,
  EuiBadge,
  EuiFlexItem,
  EuiSpacer,
  EuiText,
  EuiTextColor,
  EuiTextArea,
  EuiIcon,
  EuiFlexGroup,
  EuiTextAlign,
  EuiButtonEmpty,
  EuiConfirmModal,
  EuiAvatar,
} from '@elastic/eui';
import { admin_patient_path, field_patient_path } from '@/common/routes';
import { formatDate, DATE_WITH_DAY, TIME_FORMAT, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { PlusOneWarning } from '../patients/PlusOneWarning';

import { SidePanel } from '@/common/components/SidePanel/SidePanel';
import { Patient, Program, Service, SuggestedVisit, VisitType } from '@/common/types/index';
import styled from 'styled-components';
import { useGetVisitQuery } from '@/generated/graphql';
import { startCase } from 'lodash';
import queryString from 'query-string';

interface VisitSidePanelProps {
  program?: Program;
  visitType?: VisitType;
  services?: Service[];
  programs?: Program[];
  closeModal?: () => void;
  patient?: Patient;
  setIsEditModalOpen: (toggle: boolean) => void;
  onBackButton: () => void;
  timezone?: string;

  duration: string;
  currentUser?: any;
  selectedVisit?: SuggestedVisit;
  onSubmit: (data: { serviceInstructions: string }) => void;
  onRescheduleVisit: (data: { serviceInstructions: string; visit: any }) => void;
  disableSubmit: boolean;
  isScheduled: boolean;
  existingVisitAlayacareId?: number;
  externalId?: string;
  isFieldLayout?: boolean;
  errorMessage?: boolean;
}

const MainScroll = styled.div`
  mask-image: unset !important;
  max-height: 700px;
  font-family: Inter;
`;

const tempAuthToken = document.querySelector('meta[name=temp-auth-token]')?.getAttribute('content');

const SectionTitle = styled.h4`
  font-family: 'Inter';
  font-style: normal;
  font-weight: 700;
  font-size: 14px;
  line-height: 21px;
  color: #1a1c21;
`;

const SectionContent = styled.h4`
  font-family: 'Inter';
  font-style: normal;
  font-weight: 400;
  font-size: 16px;
  line-height: 24px;
  color: #343741;
`;

interface ArrivalWindowDateTimeProps {
  visit: {
    arrival_window_start?: string;
    arrival_window_end?: string;
    cx_start?: string;
  };
  timezone: string;
}

const ArrivalWindowDateTime: FC<ArrivalWindowDateTimeProps> = ({ visit, timezone }) => {
  return (
    <>
      <EuiTextColor style={{ fontWeight: 'bold', fontFamily: 'Inter' }}>
        <div style={{ fontSize: '19.25px', marginBottom: '12px' }}>{`${formatDate(
          visit.arrival_window_start,
          DATE_WITH_DAY,
          timezone,
        )} `}</div>
        <EuiSpacer size="s" />
        <div style={{ fontSize: '19.25px' }}>Arrival Window</div>
        <EuiSpacer size="s" />
        <div style={{ fontSize: '19.25px' }}>{`${formatDate(
          visit.arrival_window_start,
          TIME_FORMAT,
          timezone,
        )} - ${formatDate(visit.arrival_window_end, TIME_FORMAT_WITH_ZONE, timezone)}`}</div>
      </EuiTextColor>
      <EuiSpacer size="m" />
      <div>
        <SectionTitle>Target Time for Field Provider</SectionTitle>
        <SectionContent>{formatDate(visit.cx_start, TIME_FORMAT_WITH_ZONE, timezone)}</SectionContent>
      </div>
    </>
  );
};

export const VisitSidePanel: React.FC<VisitSidePanelProps> = ({
  program,
  visitType,
  duration,
  services,
  patient,
  currentUser,
  selectedVisit,
  timezone,
  setIsEditModalOpen,
  onBackButton,
  onSubmit,
  disableSubmit,
  isScheduled,
  existingVisitAlayacareId,
  onRescheduleVisit,
  externalId,
  isFieldLayout,
  errorMessage,
}) => {
  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const [instructions, setInstructions] = useState(patient?.address?.notes);
  const [showMoreVisitDetails, setShowMoreVisitDetails] = useState(false);
  const [showConfirmationModal, setShowConfirmationModal] = useState(false);
  const [plusOneWarningUnderstood, setPlusOneWarningUnderstood] = useState(false);

  const { data, error: getVisitError } = useGetVisitQuery({
    variables: {
      alayacare_visit_id: existingVisitAlayacareId,
      visit_id: externalId,
    },
  });
  const existingVisitData = data?.getVisit;
  const visitDetails = {
    existing_visit: {
      ...existingVisitData,
    },
  };

  const defaultErrorMessage =
    'Something went wrong while fetching Program information. Please try refreshing the page.';
  const error = getVisitError ? defaultErrorMessage : null;
  const existingVisit = visitDetails?.existing_visit;
  const resources = selectedVisit?.resources;

  const displayVisitDate = (visit, timezone) => (
    <>
      <div>{`${formatDate(visit?.cx_start, DATE_WITH_DAY, timezone)} `}</div>
      <div>{`${formatDate(visit?.cx_start, TIME_FORMAT, timezone)} - ${formatDate(
        visit?.cx_end,
        TIME_FORMAT_WITH_ZONE,
        timezone,
      )}`}</div>
    </>
  );

  const displayVisitDriveTimes = (visit, timezone) =>
    `${formatDate(visit?.start_time, TIME_FORMAT, timezone)} - ${formatDate(
      visit?.end_time,
      TIME_FORMAT_WITH_ZONE,
      timezone,
    )}`;

  useEffect(() => {
    if (selectedVisit?.id && instructions !== '') {
      setInstructions(patient?.address?.notes || '');
    }
  }, [selectedVisit?.id]);

  const displayBasicInformation = () => {
    if (visitDetails?.existing_visit?.id) {
      return <></>;
    }

    return (
      <>
        <EuiFlexItem grow={false}>
          <EuiText>
            <h5 style={{ fontWeight: 'bold', color: '#69707D', marginTop: '1rem' }}>Add Visit</h5>
          </EuiText>
          <EuiSpacer size="m" />
          <EuiTextColor style={{ fontWeight: 'bold' }}>
            <h4>{`${patient.first_name} ${patient.last_name}`}</h4>
          </EuiTextColor>
          <EuiSpacer size="m" />
          <SectionTitle>Program</SectionTitle>
          <SectionContent>{program?.name}</SectionContent>
          <EuiSpacer size="m" />
          <SectionTitle>Visit Type</SectionTitle>
          <SectionContent>{visitType?.name}</SectionContent>
          <EuiSpacer size="m" />
          <SectionTitle>Services</SectionTitle>
          <SectionContent>
            {services?.length > 0 &&
              services?.map((service) => <div key={`service_id_${service.id}`}>{service.name}</div>)}
          </SectionContent>
          <EuiSpacer size="m" />
          <SectionTitle>Visit Duration</SectionTitle>
          <SectionContent>{duration}m</SectionContent>
        </EuiFlexItem>
        <EuiTextAlign textAlign="right">
          <EuiButton fill type="submit" onClick={() => setIsEditModalOpen(true)}>
            Edit
          </EuiButton>
        </EuiTextAlign>
      </>
    );
  };

  const displayCurrentVisitDetails = () => {
    if (!visitDetails?.existing_visit?.id) {
      return null;
    }

    return (
      <EuiFlexItem grow={false}>
        <EuiFlexItem style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <h6 style={{ fontWeight: 'bold', color: '#69707D', fontSize: '14px' }}>Current Visit Details</h6>
          <EuiButtonEmpty size="xs" onClick={() => setIsEditModalOpen(true)}>
            Edit Info
          </EuiButtonEmpty>
        </EuiFlexItem>
        <EuiSpacer size="m" />
        <EuiTextColor style={{ fontWeight: 'bold' }}>
          {visitDetails?.existing_visit.arrival_window_start ? (
            <ArrivalWindowDateTime visit={visitDetails?.existing_visit} timezone={timezone} />
          ) : (
            <h2>{displayVisitDate(visitDetails?.existing_visit, timezone)}</h2>
          )}
        </EuiTextColor>
        <EuiSpacer size="m" />
        <SectionTitle>Field Provider</SectionTitle>
        <SectionContent>
          {visitDetails?.existing_visit?.field_provider?.first_name || 'No Field Provider'}
        </SectionContent>
        <EuiSpacer size="m" />
        <SectionTitle>Program</SectionTitle>
        <SectionContent>{program?.name || visitDetails?.existing_visit?.program?.name || ''}</SectionContent>

        {showMoreVisitDetails && (
          <>
            <EuiSpacer size="m" />
            <SectionTitle>Visit Type</SectionTitle>
            <SectionContent>{visitDetails?.existing_visit?.visitType?.name}</SectionContent>
            <EuiSpacer size="m" />
            <SectionTitle>Services</SectionTitle>
            <SectionContent>
              {services?.length > 0 &&
                services?.map((service) => <div key={`service_id_${service.id}`}>{service.name}</div>)}
            </SectionContent>
            <EuiSpacer size="m" />
            <SectionTitle>Visit Duration</SectionTitle>
            <SectionContent>{duration}</SectionContent>
          </>
        )}

        <EuiFlexItem style={{ flexDirection: 'row', justifyContent: 'right' }}>
          <EuiButtonEmpty onClick={() => setShowMoreVisitDetails(!showMoreVisitDetails)} size="xs">
            View{showMoreVisitDetails ? ' less' : ' more'}
          </EuiButtonEmpty>
        </EuiFlexItem>
      </EuiFlexItem>
    );
  };

  const displayRescheduleButtons = () => {
    if (!visitDetails?.existing_visit?.id) {
      return null;
    }
    return (
      <>
        {showConfirmationModal && (
          <EuiConfirmModal
            title="Reschedule this visit ?"
            onCancel={() => setShowConfirmationModal(false)}
            onConfirm={() => {
              onRescheduleVisit({ serviceInstructions: instructions, visit: existingVisit });
              setShowConfirmationModal(false);
            }}
            cancelButtonText="Cancel"
            confirmButtonText="Yes, Reschedule"
            defaultFocusedButton="confirm"
          />
        )}
        <EuiFlexItem>
          <EuiFlexGroup direction="column">
            {currentParams?.limit_arrival_window === 'true' && errorMessage ? (
              <EuiFlexItem>
                <EuiButton
                  fill
                  onClick={() => {
                    const url = new URL(window.location.href);
                    const searchParams = url.searchParams;
                    searchParams.set('limit_arrival_window', 'false');
                    url.search = searchParams.toString();
                    window.location.assign(url.href);
                  }}
                >
                  Ignore Arrival Window
                </EuiButton>
              </EuiFlexItem>
            ) : null}
            <EuiFlexItem>
              <EuiButtonEmpty
                onClick={() => {
                  const isNotAdmin =
                    currentUser?.account_type === 'ExternalAccount' || currentUser?.account_type === 'FieldProvider';
                  const url = isNotAdmin ? field_patient_path(patient.id) : admin_patient_path(patient.id);
                  window.location.assign(url);
                }}
              >
                Cancel Reschedule
              </EuiButtonEmpty>
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiFlexItem>
        {selectedVisit && selectedVisit?.start_time ? (
          <EuiFlexItem>
            <EuiButton fill onClick={() => setShowConfirmationModal(true)} isDisabled={disableSubmit || isScheduled}>
              Confirm
            </EuiButton>
          </EuiFlexItem>
        ) : null}
      </>
    );
  };

  const displaySelectedVisit = () => (
    <>
      <EuiFlexItem grow={false}>
        {!visitDetails?.existing_visit && (
          <EuiIcon
            onClick={onBackButton}
            type="sortLeft"
            size="m"
            style={{ marginBottom: '20px', cursor: 'pointer' }}
          />
        )}
        {visitDetails?.existing_visit && (
          <EuiText>
            <h5 style={{ fontWeight: 'bold', color: '#69707D', fontSize: '14px' }}>New Visit Details</h5>
            <EuiSpacer size="xl" />
          </EuiText>
        )}
        <EuiFlexGroup justifyContent="spaceBetween" style={{ flexGrow: 0 }}>
          <EuiText style={{ color: '#00BFB3', fontSize: 22, fontWeight: 'bold', paddingLeft: '0.95rem' }}>
            {selectedVisit?.total_score}%
          </EuiText>
          {isScheduled && (
            <EuiBadge color={'success'} style={{ marginRight: '1rem' }}>
              Scheduled
            </EuiBadge>
          )}
        </EuiFlexGroup>

        <EuiSpacer size="xl" />

        {selectedVisit?.arrival_window_start ? (
          <ArrivalWindowDateTime visit={selectedVisit} timezone={timezone} />
        ) : (
          <>
            <EuiTextColor style={{ fontWeight: 'bold' }}>
              <h4 style={{ fontSize: '22px' }}>{displayVisitDate(selectedVisit, timezone)}</h4>
            </EuiTextColor>
            <EuiSpacer size="m" />
            <SectionTitle>Route Optimized Time</SectionTitle>
            <SectionContent>{displayVisitDriveTimes(selectedVisit, timezone)}</SectionContent>
          </>
        )}
        <EuiSpacer size="m" />
        <div>
          <SectionTitle>Visit Duration</SectionTitle>
          <SectionContent>{duration}m</SectionContent>
          <EuiSpacer size="m" />

          <SectionTitle>Field Provider</SectionTitle>
          <SectionContent style={{ fontSize: '16px' }}>
            <EuiAvatar
              style={{
                width: '18px',
                height: '18px',
                fontSize: '10px',
                marginRight: '5px',
                verticalAlign: 'baseline',
              }}
              color="#d3dae6"
              size="s"
              name={selectedVisit?.fp_name || ''}
            />
            {selectedVisit?.fp_name}
          </SectionContent>
          <EuiSpacer size="m" />

          {resources?.map(({ provider_role, name }) => {
            if (name === selectedVisit?.fp_name) return null;
            return (
              <>
                <SectionTitle>{startCase(provider_role)}</SectionTitle>
                <SectionContent style={{ fontSize: '16px' }}>
                  <EuiAvatar
                    style={{
                      width: '18px',
                      height: '18px',
                      fontSize: '10px',
                      marginRight: '5px',
                      verticalAlign: 'baseline',
                    }}
                    color="#d3dae6"
                    size="s"
                    name={name || ''}
                  />
                  {name}
                </SectionContent>
                <EuiSpacer size="m" />
              </>
            );
          })}
          <SectionTitle>Expected Drive Time</SectionTitle>
          <SectionContent>{selectedVisit?.expected_drive}m</SectionContent>
          <EuiSpacer size="m" />

          <SectionTitle>Visit Type</SectionTitle>
          <SectionContent>{visitType?.name}</SectionContent>
          <EuiSpacer size="m" />

          <SectionTitle>Services</SectionTitle>
          {services &&
            services.length > 0 &&
            services.map((service) => (
              <SectionContent key={`service_id_${service.id}`} style={{ marginBottom: '5px' }}>
                {service.name}
              </SectionContent>
            ))}
          <EuiSpacer size="m" />
        </div>

        <SectionTitle>Service Instructions</SectionTitle>
        <EuiTextArea
          placeholder="Parking instructions, door code, anything patient wants field provider to know prior to the visit."
          value={instructions}
          onChange={(e) => setInstructions(e.target.value)}
          style={{
            height: '82px',
            marginBottom: visitDetails.existing_visit || services.length > 2 ? '70px' : '40px',
          }}
          aria-label="Use aria labels when no actual label is in use"
        />
      </EuiFlexItem>
    </>
  );
  return (
    <SidePanel error={error} justifyContent="flexStart" isFieldLayout={isFieldLayout}>
      <MainScroll className="eui-yScrollWithShadows">
        {existingVisitData?.visitGroup && (
          <PlusOneWarning
            visitGroup={existingVisitData?.visitGroup}
            plusOneWarningUnderstood={plusOneWarningUnderstood}
            setPlusOneWarningUnderstood={setPlusOneWarningUnderstood}
            current_user={currentUser}
            verb={'reschedule'}
            currentPatientId={patient.id}
          />
        )}
        {(!existingVisitData?.visitGroup || plusOneWarningUnderstood === true) && (
          <>
            {displayCurrentVisitDetails()}
            {selectedVisit && selectedVisit?.start_time ? displaySelectedVisit() : displayBasicInformation()}
          </>
        )}
      </MainScroll>
      <EuiFlexGroup
        gutterSize="none"
        style={{
          position: 'absolute',
          bottom: '-18px',
          borderTop: selectedVisit?.start_time ? '1px solid rgb(211, 218, 230)' : '',
          width: '118%',
          marginLeft: '-24px',
          padding: '12px 20px',
          background: 'white',
        }}
      >
        {displayRescheduleButtons()}
        {selectedVisit && selectedVisit?.start_time && !visitDetails.existing_visit?.cx_start && (
          <EuiTextAlign textAlign="right" style={{ width: '100%' }}>
            <EuiSpacer size="m" />
            <EuiButton
              fill
              onClick={() => onSubmit({ serviceInstructions: instructions })}
              isDisabled={disableSubmit || isScheduled}
            >
              Confirm
            </EuiButton>
          </EuiTextAlign>
        )}
      </EuiFlexGroup>
    </SidePanel>
  );
};
