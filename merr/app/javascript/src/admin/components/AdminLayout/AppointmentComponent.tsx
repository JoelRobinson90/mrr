import React from 'react';
import moment from 'moment';
import {
  EuiBadge,
  EuiFlexGroup,
  EuiAvatar,
  EuiFlexItem,
  EuiText,
  EuiIcon,
  EuiAccordion,
  EuiPage,
  EuiPageBody,
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageContentHeaderSection,
  EuiPanel,
  EuiTitle,
  EuiSpacer,
} from '@elastic/eui';
import { htmlIdGenerator } from '@elastic/eui/lib/services';
import { Appointment } from '@/common/types';
import { formatDate } from '@/common/utils/dates/dates';
import { MedArriveBadge } from '@/admin/components/AdminLayout/MedArriveStatusBadge';
import { PatientsTable } from '../PatientsTable/PatientsTable';

export interface Props {
  appointment: Appointment;
}

export const AppointmentComponent: React.FC<Props> = ({ appointment }) => {
  const { status, patient, start_time } = appointment;
  const getDays = () => moment(formatDate(start_time, 'YYYYMMDD')).fromNow();

  const createExtraAction = () => (
    <EuiFlexGroup gutterSize="m" responsive={false} direction="column">
      <EuiFlexItem grow={false}>
        <EuiFlexGroup gutterSize="s">
          <EuiFlexItem grow={false}>
            <EuiBadge iconType="mapMarker" color="hollow">
              Dallas, Texas
            </EuiBadge>
          </EuiFlexItem>
          <EuiFlexItem grow={false}>
            <MedArriveBadge status={status} />
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexItem>
      <EuiFlexItem grow={false}>
        <EuiText size="s" color="subdued" textAlign="center">
          <em style={{ color: '#006BB4' }}>in {getDays().replace('ago', '')}</em>
        </EuiText>
      </EuiFlexItem>
    </EuiFlexGroup>
  );

  const createButtonContent = () => (
    <EuiFlexGroup gutterSize="m" responsive={false}>
      <EuiFlexItem grow={false}>
        <EuiAvatar size="m" name={`${patient.first_name} ${patient.last_name}`} />
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiFlexGroup direction="column" gutterSize="none">
          <EuiFlexItem>
            <EuiText style={{ color: '#006BB4' }}>{`${patient.first_name} ${patient.last_name}`}</EuiText>
          </EuiFlexItem>
          <EuiFlexItem>
            <EuiText size="s" color="subdued">
              Parademic
            </EuiText>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiText textAlign="center">
          <EuiIcon type="sortRight" color="primary" size="l" />
        </EuiText>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiFlexGroup direction="column" gutterSize="none">
          <EuiFlexItem>
            <EuiText style={{ color: '#006BB4' }}>{`${patient.first_name} ${patient.last_name}`}</EuiText>
          </EuiFlexItem>
          <EuiFlexItem>
            <EuiText size="s" color="subdued">
              Millenium Physician Group
            </EuiText>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiText style={{ color: '#006BB4' }}>@{formatDate(start_time, 'h:mmA')} CST</EuiText>
      </EuiFlexItem>
    </EuiFlexGroup>
  );

  return (
    <EuiPanel>
      <EuiAccordion
        id={htmlIdGenerator()()}
        buttonContent={createButtonContent()}
        extraAction={createExtraAction()}
        arrowDisplay="right"
      >
        <EuiPage>
          <EuiPageBody component="div">
            <EuiPageContent>
              <EuiPageContentHeader>
                <EuiPageContentHeaderSection>
                  <EuiTitle>
                    <h2>Appointment Details</h2>
                  </EuiTitle>
                </EuiPageContentHeaderSection>
              </EuiPageContentHeader>
              <EuiPageContentBody>
                <div>
                  <h6>
                    {formatDate(appointment.start_time, 'MMMM Do, YYYY')} /{' '}
                    {formatDate(appointment.start_time, 'h:mma')} - {formatDate(appointment.end_time, 'h:mma')}
                  </h6>
                  <EuiSpacer size="m" />
                  {appointment.patient ? (
                    // A little ice!! We can decide what we want to render here
                    <PatientsTable data={[patient]} />
                  ) : (
                    <>
                      <EuiSpacer size="m" />
                      <EuiText textAlign="center">There are NO patients booked for this appointment</EuiText>
                    </>
                  )}
                </div>
              </EuiPageContentBody>
            </EuiPageContent>
          </EuiPageBody>
        </EuiPage>
      </EuiAccordion>
    </EuiPanel>
  );
};
