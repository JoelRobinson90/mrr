import { appointmentDisplayTime, appointmentDisplayDate } from '@/common/utils/dates/dates';
import { EuiFlexGroup, EuiFlexItem, EuiPanel, EuiSpacer, EuiText, EuiBadge, EuiNotificationBadge } from '@elastic/eui';
import styled from 'styled-components';
import { Appointment } from '@/common/types';
import React from 'react';
import { EuiSpacerProps } from '@elastic/eui/src/components/spacer/spacer';
import { googleMapsUrl, formattedAddressComponents } from '@/common/utils/addresses/addresses';
import { StatusStyled } from '@/common/components/MedStatusDropdown/MedStatusDropdown';
import { STATUS_COLOR_MAP } from '@/common/components/MedBadge/MedBadge';
import { TagLabel } from '@/common/components/Tag/Tag';

const FlexItemStyled = styled(EuiFlexItem)`
  && {
    margin: 0;
    display: block;
    @media (min-width: 768px) {
      display: flex;
    }
    @media (min-width: 1400px) {
      margin: 12px;
    }
  }
`;

const ShowStatus = styled(StatusStyled)`
  font-size: 14px;
  font-weight: 600;
  color: #233b74;
`;

const ContentInfo = styled.div`
  margin: auto 10px;
  @media (min-width: 1235px) {
    min-width: 130px;
  }
  @media (min-width: 1400px) {
    margin-left: 20px;
    margin-right: 20px;
    min-width: 170px;
  }
`;

const TextStyled = styled.div`
  font-size: 14px;
  color: #243045;
`;

const TitleStyled = styled.div`
  position: relative;
  display: inline-block;
  font-size: 14px;
  color: #243045;
  font-weight: 600;
  line-height: 1.3;
  @media (min-width: 1035px) {
    line-height: 2;
  }
  &:hover {
    color: #006bb4;
    text-decoration: underline;
    span {
      visibility: visible;
    }
  }
`;

const Tooltip = styled.span`
  visibility: hidden;
  width: 120px;
  background-color: rgb(210, 218, 231, 0.9);
  color: #243045;
  text-align: center;
  border-radius: 3px;
  padding: 5px 0;
  position: absolute;
  z-index: 1;
  margin-left: -60px;
  bottom: 100%;
  left: 50%;
  font-size: 12px;
`;

const LineStyled = styled(EuiSpacer)`
  border-right: solid 1px #d2dae7;
  height: 55px;
  display: none;
  @media (min-width: 768px) {
    display: block;
  }
`;

const StyledEuiNotificationBadge = styled(EuiNotificationBadge)`
  background-color: orange;
  height: 22px;
  width: 22px;
  display: flex;
  border-radius: 11px;
  justify-content: center;
  align-items: center;
  margin-left: 4px;
`;

const AppointmentId = styled.div`
  position: absolute;
  top: 0;
  right: 0;
  border: solid 1px #dfe5ee;
  color: #898c90;
  padding: 2px 4px;
  font-size: 14px;
`;

type AppointmentAccordionProps = {
  appointment: Appointment;
  spacerSize?: EuiSpacerProps['size'];
  hasSpacer?: boolean;
  disableAccordion?: 'open' | 'closed';
};

export const AppointmentAccordion: React.FC<AppointmentAccordionProps> = ({
  appointment,
  spacerSize = 'm',
  hasSpacer = true,
}) => {
  const { patient, field_provider, status, address, tags, vaccine_quantity, duration, drive_time } = appointment;
  const { demand_partner, display_name } = patient;

  const openMapAddress = (e) => {
    e.preventDefault();
    window.open(googleMapsUrl(address), '_blank');
  };

  const goPatient = (e) => {
    e.preventDefault();
    window.location.href = `/admin/patients/${patient.id}`;
  };

  const extra_vaccines = vaccine_quantity ? vaccine_quantity - 1 : null;

  return (
    <>
      <EuiPanel name="appointmentCard" hasShadow={false} style={{ position: 'relative' }}>
        <AppointmentId>{appointment.id}</AppointmentId>
        <div style={{ margin: 'auto 20px' }} data-test-id={`tags-${appointment.id}`}>
          {tags?.length ? tags.map((tag) => <TagLabel key={tag.name} tag={tag} />) : ''}
        </div>
        <EuiFlexGroup style={{ margin: 0 }} alignItems="center">
          <FlexItemStyled grow={false}>
            <ContentInfo>
              <TitleStyled
                style={{ fontSize: 16, display: 'flex', flexDirection: 'row', alignItems: 'center' }}
                onClick={goPatient}
              >
                {display_name}
                {extra_vaccines > 0 && <StyledEuiNotificationBadge>+{extra_vaccines}</StyledEuiNotificationBadge>}
                <Tooltip>View patient</Tooltip>
              </TitleStyled>
              <TextStyled>{patient.display_phone_number}</TextStyled>
              <TextStyled>
                {demand_partner?.name}{' '}
                {patient.consent_to_text && (
                  <EuiBadge color="secondary" style={{ margin: '0 0.4em' }}>
                    SMS Consent
                  </EuiBadge>
                )}
              </TextStyled>
            </ContentInfo>
          </FlexItemStyled>
          <LineStyled />
          <FlexItemStyled grow={false}>
            <ContentInfo>
              <TitleStyled>Date {'\u2022'} Time</TitleStyled>
              <TextStyled>
                {appointmentDisplayDate(appointment)}
                <br />
                {appointmentDisplayTime(appointment)} {duration ? `(${duration} min)` : null}
              </TextStyled>
            </ContentInfo>
          </FlexItemStyled>
          <LineStyled />
          <FlexItemStyled grow={false}>
            <ContentInfo>
              <TitleStyled>Location</TitleStyled>
              <TextStyled onClick={openMapAddress}>
                {address && formattedAddressComponents(address).join(', ')}
              </TextStyled>
            </ContentInfo>
          </FlexItemStyled>
          <LineStyled />
          <FlexItemStyled grow={false}>
            <ContentInfo>
              {field_provider ? (
                <>
                  <TitleStyled>{field_provider?.display_name}</TitleStyled>
                  <TextStyled>{field_provider?.provider_level}</TextStyled>
                </>
              ) : (
                <span style={{ color: '#bf2c23', fontSize: 14, fontWeight: 600 }}>Unassigned</span>
              )}
            </ContentInfo>
          </FlexItemStyled>
          <FlexItemStyled style={{ alignItems: 'flex-end' }}>
            <div>
              <ShowStatus button color={STATUS_COLOR_MAP[status]}>
                {status}
              </ShowStatus>
            </div>
          </FlexItemStyled>
        </EuiFlexGroup>
      </EuiPanel>
      {hasSpacer ? <EuiSpacer size={spacerSize} /> : null}
    </>
  );
};
