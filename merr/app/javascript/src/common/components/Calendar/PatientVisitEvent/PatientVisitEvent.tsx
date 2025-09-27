import { calculateInfoColor } from '@/common/utils/calendar/utils';
import { EuiFlexGroup, EuiFlexItem, EuiIcon } from '@elastic/eui';
import { MbscCalendarEvent, MbscCalendarEventData } from '@mobiscroll/react';
import React from 'react';
import styled, { css } from 'styled-components';

type PatientVisitEventProps = {
  event: MbscCalendarEventData;
  titleContent: string;
  secondaryTitle: string;
  selected?: boolean;
  timezone: string;
  extraContent?: JSX.Element;
  showIcon?: boolean;
  maxHeight?: string;
  minHeight?: string;
  highlighted?: boolean;
};

interface CustomContainerProps {
  backgroundColor: string;
  borderColor: string;
  borderWidth: number;
}

const CustomContainer = styled.div<CustomContainerProps>`
  background: ${({ backgroundColor }) => backgroundColor};
  border-radius: 6px;
  width: 100%;
  overflow: hidden;
  font-size: 14px;
  text-transform: capitalize;
  white-space: nowrap;
  ${({ borderColor, borderWidth }) =>
    css`
      border: ${borderWidth}px solid ${borderColor};
    `}
`;

const HighlightedDot = styled.div`
  position: absolute;
  top: 4px;
  right: 4px;
  width: 9px;
  height: 9px;
  background: #bd271e;
  border-radius: 50px;
`;

export const PatientVisitEvent: React.FC<PatientVisitEventProps> = ({
  event,
  titleContent,
  secondaryTitle,
  extraContent,
  selected,
  maxHeight,
  minHeight,
  showIcon = true,
  highlighted,
}) => {
  const visit = event?.original;
  const backgroundColor = '#00BFB3';

  let iconName = 'check';

  switch (visit.status) {
    case 'cancelled':
      iconName = 'cross';
      break;
    default:
      iconName = 'clock';
      break;
  }

  const infoColor = calculateInfoColor(visit);

  return (
    <CustomContainer
      style={{ maxHeight, minHeight }}
      backgroundColor={infoColor.backgroundColor || backgroundColor}
      borderColor={infoColor.text}
      borderWidth={selected ? 2 : 1}
    >
      {highlighted && <HighlightedDot />}
      <EuiFlexGroup
        gutterSize="none"
        style={{ textOverflow: 'ellipsis', overflow: 'hidden', padding: '10px', flexWrap: 'wrap' }}
      >
        {showIcon && <EuiIcon type={iconName} color={infoColor.text} />}
        <EuiFlexItem style={{ fontSize: '11px', color: infoColor.text, fontWeight: 500, paddingLeft: '2px' }}>
          {visit?.confirmed && titleContent === 'Scheduled' ? 'Confirmed' : titleContent}
        </EuiFlexItem>
        <EuiFlexItem
          style={{
            color: '#69707D',
            textAlign: 'right',
            paddingRight: '2px',
            fontSize: '10.5px',
            fontWeight: 400,
            textOverflow: 'ellipsis',
            overflow: 'hidden',
          }}
        >
          {' '}
          {secondaryTitle}
        </EuiFlexItem>
        <div style={{ flexBasis: '100%', height: 0 }}></div>
        {extraContent}
      </EuiFlexGroup>
    </CustomContainer>
  );
};
