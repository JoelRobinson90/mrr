import { formatDate } from '@/common/utils/dates/dates';
import { EuiFlexGroup, EuiFlexItem, EuiText } from '@elastic/eui';
import { CalendarNext, CalendarPrev, CalendarToday, MbscCalendarEventData } from '@mobiscroll/react';
import moment from 'moment';
import React from 'react';
import styled from 'styled-components';

type Props = {
  date: moment.Moment;
};

const CustomContainer = styled(EuiFlexGroup)`
  background: #ffffff;
  width: 100%;
`;

const StyledCalendarToday = styled(CalendarToday)`
  &&& {
    color: #343741;
    font-size: 14px;
    background: rgba(171, 180, 196, 0.1);
    border-radius: 6px;
    width: 86px;
    height: 32px;
  }
`;

const MonthYearTitle = styled(EuiText)`
  font-weight: 700;
  font-size: 22px;
  line-height: 32px;
  color: #343741;
`;

export const CalendarCustomHeader: React.FC<Props> = ({ date }) => {
  return (
    <CustomContainer>
      <EuiFlexItem>
        <MonthYearTitle>{formatDate(date, 'MMMM YYYY')}</MonthYearTitle>
      </EuiFlexItem>
      <EuiFlexItem style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'end' }}>
        <StyledCalendarToday />
        <CalendarPrev />
        <CalendarNext />
      </EuiFlexItem>
    </CustomContainer>
  );
};
