import useFilters, { FILTERS_SCHEDULE_FILTER_ID } from '@/common/hooks/useFilters/useFilters';
import { EuiFlexGroup, EuiFlexItem, EuiText, EuiDatePicker, EuiButtonGroup } from '@elastic/eui';
import { CalendarNav, CalendarPrev, CalendarToday, CalendarNext } from '@mobiscroll/react';
import { debounce } from 'lodash';
import moment from 'moment';
import React, { useCallback, useEffect, useState } from 'react';

interface ScheduleCalendarHeaderProps {
  startOfCalendar: moment.Moment;
  onDateChange: (date: moment.Moment) => void;
  onChangeView: (view: string) => void;
  calendarView: string;
}

export const SCHEDULE_CALENDAR_DATE_FILTER_KEY = 'schedule_calendar_filter_key';
export const SCHEDULE_CALENDAR_VIEW_FILTER_KEY = 'schedule_calendar_view_filter_key';

const ScheduleCalendarHeader: React.FC<ScheduleCalendarHeaderProps> = ({
  startOfCalendar,
  onChangeView,
  calendarView,
  onDateChange,
}) => {
  const [toggleCompressedIdSelected, setToggleCompressedIdSelected] = useState(calendarView);
  const { updateFilter } = useFilters();

  const toggleButtonsCompressed = [
    {
      id: 'day',
      label: 'Day',
    },
    {
      id: 'week',
      label: 'Week',
    },
  ];

  useEffect(() => {
    setToggleCompressedIdSelected(calendarView);
  }, [calendarView]);

  const onChangeCompressed = useCallback(
    debounce((optionId) => {
      setToggleCompressedIdSelected(optionId);
      onChangeView(optionId);
    }, 100),
    [],
  );

  return (
    <React.Fragment>
      <EuiFlexGroup style={{ alignItems: 'center' }}>
        <CalendarNav className="md-work-week-nav" />

        <EuiFlexItem style={{ flexDirection: 'row', alignItems: 'center', maxWidth: '300px' }}>
          <EuiFlexItem style={{ textAlign: 'right', paddingRight: '1rem' }}>
            <EuiText style={{ fontSize: '13px', fontWeight: '700' }}>Select Date</EuiText>
          </EuiFlexItem>
          <EuiFlexItem>
            <EuiDatePicker
              selected={startOfCalendar}
              onChange={(date) => {
                updateFilter(FILTERS_SCHEDULE_FILTER_ID, SCHEDULE_CALENDAR_DATE_FILTER_KEY, date.format('Y-M-D'));
                onDateChange(date);
              }}
              placeholder="Start"
            />
          </EuiFlexItem>
        </EuiFlexItem>

        <EuiFlexItem style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'end' }}>
          <EuiFlexItem style={{ flexDirection: 'row', maxWidth: '250px' }}>
            <CalendarPrev className="md-work-week-prev" />
            <CalendarToday className="md-work-week-today" />
            <CalendarNext className="md-work-week-next" />
          </EuiFlexItem>

          <EuiButtonGroup
            style={{ minWidth: '260px' }}
            name="view"
            legend="Week/Day view"
            options={toggleButtonsCompressed}
            idSelected={toggleCompressedIdSelected}
            onChange={(id) => {
              updateFilter(FILTERS_SCHEDULE_FILTER_ID, SCHEDULE_CALENDAR_VIEW_FILTER_KEY, id);
              onChangeCompressed(id);
            }}
            buttonSize="compressed"
            isFullWidth
          />
        </EuiFlexItem>
      </EuiFlexGroup>
    </React.Fragment>
  );
};

export default ScheduleCalendarHeader;
