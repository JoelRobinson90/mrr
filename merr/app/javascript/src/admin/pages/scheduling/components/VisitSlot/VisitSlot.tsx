import { formatDate, TIME_FORMAT_NO_AM, TIME_FORMAT_NO_M } from '@/common/utils/dates/dates';
import { EuiAvatar, EuiFlexGroup, EuiFlexItem, EuiToolTip } from '@elastic/eui';
import { MbscCalendarEventData } from '@mobiscroll/react';
import React from 'react';
import styled from 'styled-components';
import { VISIT_RANK_CATEGORIES } from '../../SchedulerUtils';
import { some } from 'lodash';

const PREFERRED_PROVIDER_COLOR = '#0055B1';
const DEFAULT_PROVIDER_COLOR = '#d3dae6';

type VisitSlotProps = {
  event: MbscCalendarEventData;
  selected: boolean;
  scheduledVisit?: boolean;
  timezone: string;
};

interface CustomContainerProps {
  borderColor: string;
  selected: boolean;
}

const calculateBackgroundColor = (props) => {
  if (props.selected) {
    return `${props.borderColor}2e`;
  } else if (props.scheduledVisit) {
    return `red`;
  } else {
    return `#ffffff`;
  }
};

const CustomShowFor = styled.div`
  display: none;
  position: relative;
  top: -4px;
  @media (min-width: 1560px) {
    display: inline-block;
  }
`;

const CustomContainer = styled.div<CustomContainerProps>`
  background: ${(props) => calculateBackgroundColor(props)};
  box-shadow: 0px 0.7px 1.4px rgba(0, 0, 0, 0.07), 0px 1.9px 4px rgba(0, 0, 0, 0.05), 0px 4.5px 10px rgba(0, 0, 0, 0.05);
  border-radius: 6px;
  width: 100%;
  overflow: hidden;
`;

interface TopBorderProps {
  color: string;
  width: number;
}

interface Resource {
  name: string;
  preferred: boolean;
}

interface ExtraResourceSlotProps {
  resources: Resource[];
}

const ExtraResourceSlot: React.FC<ExtraResourceSlotProps> = ({ resources }) => {
  if (!resources?.length || resources?.length === 1) return null;

  const extractInitials = (fullName) => {
    if (!fullName) return null;
  
    const names = fullName.trim().split(/\s+/);
    if (names.length === 0) return null;
  
    const initials = names.map(name => name[0]);
    return initials.join(' ');
  };

  return (
    <>
      {
        resources.slice(1).map((resource) => {
          if (!resource?.name) return null;
          return (
            <div
              style={{
                width: '16px',
                height: '16px',
                fontSize: '8px',
                marginLeft: 'calc(7% - 15px)',
                border: '1px solid #FFFFFF',
                background: resource.preferred ? PREFERRED_PROVIDER_COLOR : DEFAULT_PROVIDER_COLOR,
                borderRadius: '100%',
                color: resource.preferred ? 'white' : 'black',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                zIndex: 1,
                letterSpacing: '-1px'
              }}
            >
              {extractInitials(resource.name)}
            </div>
          );
        })
      }
    </>
  );
}

const TopBorder = styled.div<TopBorderProps>`
  background: ${(props) => props.color};
  height: 2px;
  width: ${(props) => `${props.width}%`};
`;

export const VisitSlot: React.FC<VisitSlotProps> = ({ event, selected, timezone }) => {
  const visit = event?.original;
  const resources = visit?.resources;
  let dateTime = formatDate(visit.start.toString(), TIME_FORMAT_NO_M, timezone);

  if (visit.arrival_window_start) {
    dateTime = `${formatDate(visit.arrival_window_start, TIME_FORMAT_NO_AM, timezone)}-${formatDate(
      visit.arrival_window_end,
      TIME_FORMAT_NO_AM,
      timezone,
    )}`;
  }

  let borderColor = '#00BFB3';
  switch (visit.rank_category) {
    case VISIT_RANK_CATEGORIES.BEST:
      borderColor = '#00BFB3';
      break;
    case VISIT_RANK_CATEGORIES.AVERAGE:
      borderColor = '#FEC514';
      break;
    case VISIT_RANK_CATEGORIES.WORST:
      borderColor = '#BD271E';
      break;
    default:
      break;
  }
  const content = (
    <EuiFlexGroup gutterSize="none">
      <EuiFlexItem
        style={{ color: '#343741', fontSize: '0.65vw', fontWeight: 500, paddingLeft: '5px', paddingRight: '8px' }}
      >
        {dateTime}
      </EuiFlexItem>
      <EuiAvatar
        style={{ width: '16px', height: '16px', fontSize: '8px', border: '1px solid #FFFFFF', overflow: 'hidden' }}
        color={resources[0]?.preferred ? PREFERRED_PROVIDER_COLOR : DEFAULT_PROVIDER_COLOR}
        size="s"
        name={visit.title}
      />
      <ExtraResourceSlot resources={resources} />
      <EuiFlexItem style={{ color: borderColor, fontSize: '0.68vw', textAlign: 'right', paddingRight: '5px' }}>
        {visit.total_score}%
      </EuiFlexItem>
    </EuiFlexGroup>
  );

  return (
    <CustomContainer selected={selected} borderColor={borderColor} className="mbsc-schedule-event">
      <TopBorder width={visit.total_score} color={borderColor} />
      {visit.arrival_window_start ? (
        <EuiToolTip position="top" content="Arrival Window" display="block">
          {content}
        </EuiToolTip>
      ) : (
        content
      )}
    </CustomContainer>
  );
};
