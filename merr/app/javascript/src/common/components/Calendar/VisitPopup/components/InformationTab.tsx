import { AlayacareVisit } from '@/common/types';
import {
  EuiButtonEmpty,
  EuiDescriptionList,
  EuiFlexItem,
  EuiSpacer,
  EuiText,
  EuiFlexGroup,
  EuiIcon,
  EuiLink,
  EuiCopy,
} from '@elastic/eui';
import { startCase } from 'lodash';
import React, { FC } from 'react';
import PatientSearch from '@/admin/pages/patients/PatientSearch';
import { DATE_WITH_DAY, formatDate, TIME_FORMAT, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { CopyToClipboard } from '@/common/components/CopyToClipboard/CopyToClipboard';
import { PatientLinks } from '@/common/components/Calendar/VisitPopup/components/PatientLinks';
import { googleMapsUrl } from '@/common/utils/addresses/addresses';
import moment from 'moment';
import styled from 'styled-components';

interface VisitPopupActionsProps {
  visit: AlayacareVisit;
  isAddingPatient: Boolean;
  visitGroup: any;
  setSelectedPatient: any;
  selectedOptions: any;
  isAdmin: any;
  setIsAddingPatient: any;
  current_user: any;
  onRescheduleVisit: any;
  providers: any;
}

const CustomItemList = styled(EuiDescriptionList)`
  &&&& {
    dt {
      font-weight: bold;
      font-size: 12px;
      color: #1a1c21;
    }
    dd {
      font-weight: normal;
      font-size: 14px;
      color: #343741;
    }
  }
`;

export const InformationTab: FC<VisitPopupActionsProps> = ({
  onRescheduleVisit,
  current_user,
  setIsAddingPatient,
  isAdmin,
  isAddingPatient,
  visitGroup,
  setSelectedPatient,
  selectedOptions,
  visit,
  providers,
}) => {
  const visitTypeName = visit?.visit_type?.name;
  const fieldProviderName = visit.fp_name || '';
  const currentPatient = visit?.patient;
  const timezone = currentPatient?.address?.timezone;
  const startTime = visit?.start_time;
  const endTime = visit?.end_time;

  const duration = moment(endTime).diff(moment(startTime), 'minutes');

  const displayAddress = () => {
    if (visit.patient.address.address_line_two) {
      return `${visit.patient.address.address_line_one} ${visit.patient.address.address_line_two}, ${visit.patient.address.city}, ${visit.patient.address.state} ${visit.patient.address.zipcode}`;
    } else {
      return `${visit.patient.address.address_line_one}, ${visit.patient.address.city}, ${visit.patient.address.state} ${visit.patient.address.zipcode}`;
    }
  };

  const arrivalTimeWindow = visit.arrival_window_start
    ? `${formatDate(visit.arrival_window_start, TIME_FORMAT, timezone)} - ${formatDate(
        visit.arrival_window_end,
        TIME_FORMAT_WITH_ZONE,
        timezone,
      )}`
    : null;

  const visitItems = [
    !!arrivalTimeWindow
      ? {
          title: <b style={{ fontSize: '14px' }}>Arrival Window</b>,
          description: <b style={{ fontSize: '14px' }}>{arrivalTimeWindow}</b>,
        }
      : null,
    !!visitTypeName
      ? {
          title: 'Visit Type',
          description: <CopyToClipboard text={visitTypeName} />,
        }
      : null,
    !!arrivalTimeWindow
      ? {
          title: 'Target Time',
          description: formatDate(visit.cx_start, TIME_FORMAT_WITH_ZONE, timezone),
        }
      : null,
    visit?.patient
      ? {
          title: 'Patient',
          description: (
            <>
              <EuiFlexGroup style={{ alignItems: 'center' }}>
                <EuiFlexItem style={{ minWidth: '150px', wordWrap: 'break-word' }}>
                  <PatientLinks visit={visit} isAdmin={isAdmin} visitGroup={visitGroup} />
                </EuiFlexItem>
                {visit?.visit_type?.plus_ones_enabled && visit.status === 'scheduled' && (
                  <EuiFlexItem style={{ margin: 0 }}>
                    <EuiButtonEmpty style={{ fontSize: '14px' }} onClick={() => setIsAddingPatient(true)}>
                      Add Patient
                    </EuiButtonEmpty>
                  </EuiFlexItem>
                )}
              </EuiFlexGroup>
            </>
          ),
        }
      : null,
    {
      title: 'Field Provider',
      description: (
        <>
          <EuiFlexGroup style={{ alignItems: 'center' }}>
            <EuiFlexItem style={{ minWidth: '150px' }}>{fieldProviderName || 'Unassigned'}</EuiFlexItem>
            {visit.status !== 'completed' &&
              (!visit.cancelled || visit.status !== 'cancelled') &&
              current_user?.account_type !== 'FieldProvider' && (
                <EuiFlexItem style={{ margin: 0 }}>
                  <EuiButtonEmpty style={{ fontSize: '14px' }} onClick={() => onRescheduleVisit(true, false)}>
                    Change
                  </EuiButtonEmpty>
                </EuiFlexItem>
              )}
          </EuiFlexGroup>
        </>
      ),
    },
    {
      title: 'Services',
      description: (
        <EuiFlexItem>
          {visit?.services?.map((s) => (
            <div key={s.id}>
              <CopyToClipboard text={s.name} />
            </div>
          ))}
        </EuiFlexItem>
      ),
    },
    {
      ...(visit?.athena_telehealth_url
        ? {
            title: '',
            description: (
              <EuiFlexItem>
                <EuiCopy textToCopy={visit?.athena_telehealth_url}>
                  {(copy) => (
                    <>
                      <a target="_blank" href={visit?.athena_telehealth_url} rel="noreferrer">
                        Athena Telehealth Link&nbsp;
                      </a>
                      <EuiIcon
                        onClick={(e) => {
                          copy();
                          e.stopPropagation();
                        }}
                        type="copy"
                        color="primary"
                        size="m"
                      />
                    </>
                  )}
                </EuiCopy>
              </EuiFlexItem>
            ),
          }
        : null),
    },
    {
      title: 'Address',
      description: (
        <EuiLink href={googleMapsUrl(visit?.patient?.address)} external target="_blank">
          <EuiFlexItem style={{ maxHeight: '73px' }}>
            {visit?.patient?.address ? displayAddress() : 'No patient address'}
          </EuiFlexItem>
        </EuiLink>
      ),
    },
    {
      title: 'Visit duration',
      description: `${duration} min`,
    },
    {
      title: 'Visit identifier',
      description: <CopyToClipboard text={visit.visit_id} />,
    },
  ].filter(Boolean);

  const visitItemsIndex = visitItems.findIndex((v) => v.title === 'Field Provider');

  providers?.forEach(({ role, first_name, last_name }) => {
    const name = `${first_name} ${last_name}`;
    if (fieldProviderName !== name)
      visitItems.splice(visitItemsIndex + 1, 0, {
        title: role ? startCase(role) : 'Unassigned',
        description: (
          <>
            <EuiFlexGroup style={{ alignItems: 'center' }}>
              <EuiFlexItem style={{ minWidth: '150px' }}>{name || 'Unassigned'}</EuiFlexItem>
            </EuiFlexGroup>
          </>
        ),
      });
  });

  return isAddingPatient ? (
    <PatientSearch
      patient={currentPatient}
      groupVisits={visitGroup?.visits}
      setSelected={setSelectedPatient}
      selectedOptions={selectedOptions}
      visit={visit}
    />
  ) : (
    <>
      <EuiText style={{ fontWeight: 700, fontSize: '22px', color: 'black' }}>
        {formatDate(visit.start, DATE_WITH_DAY)}
      </EuiText>

      {!arrivalTimeWindow && (
        <>
          <EuiSpacer size="s" />
          <EuiText style={{ fontWeight: 700, fontSize: '22px', color: 'black' }}>
            {formatDate(visit.cx_start, TIME_FORMAT, timezone)} -{' '}
            {formatDate(visit.cx_end, TIME_FORMAT_WITH_ZONE, timezone)}
          </EuiText>
        </>
      )}
      <EuiSpacer size="m" />
      <CustomItemList textStyle="reverse" style={{ color: 'black' }} listItems={visitItems} />
    </>
  );
};
