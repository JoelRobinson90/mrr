import { Eventcalendar } from '@mobiscroll/react';
import '@mobiscroll/react/dist/css/mobiscroll.react.min.css';
import styled from 'styled-components';

interface CustomMedEventProps {
  eventMarginBottom?: string;
  timelineResourceMinHeight?: string;
}

const StyledMedEventcalendar = styled(Eventcalendar)<CustomMedEventProps>`
  &&& {
    font-family: 'Inter', sans-serif;
    overflow: visible;

    div.mbsc-calendar-week-days {
      background: white;
      div.mbsc-calendar-week-day {
        text-align: center;
      }
    }

    .mbsc-calendar-cell {
      color: #69707d;
      font-weight: 500;
    }

    .mbsc-ios.mbsc-calendar-header,
    .mbsc-ios.mbsc-calendar-day:after,
    .mbsc-calendar-cell {
      border-color: rgba(19, 34, 149, 0.1);
      background: white !important;
    }

    .mbsc-calendar-text.mbsc-ltr {
      margin-bottom: ${(props) => props.eventMarginBottom || 'inherit'};
    }

    .mbsc-timeline-resource.mbsc-ios.mbsc-ltr {
      min-height: ${(props) => props.timelineResourceMinHeight || 'inherit'};
      display: flex;
      align-items: center;
    }

    .mbsc-timeline-column,
    .mbsc-timeline-header-column {
      width: 160px;
    }

    .mbsc-ios.mbsc-schedule-all-day-item:after,
    .mbsc-ios.mbsc-schedule-column,
    .mbsc-ios.mbsc-schedule-item,
    .mbsc-ios.mbsc-schedule-resource,
    .mbsc-ios.mbsc-schedule-resource-group,
    .mbsc-ios.mbsc-timeline-column,
    .mbsc-ios.mbsc-timeline-day:after,
    .mbsc-ios.mbsc-timeline-header,
    .mbsc-ios.mbsc-timeline-header-column,
    .mbsc-ios.mbsc-timeline-header-date,
    .mbsc-ios.mbsc-timeline-header-month,
    .mbsc-ios.mbsc-timeline-header-week,
    .mbsc-ios.mbsc-timeline-resource,
    .mbsc-ios.mbsc-timeline-resource-empty,
    .mbsc-ios.mbsc-timeline-slot-header,
    .mbsc-ios.mbsc-timeline-slots {
      border-color: rgba(19, 34, 149, 0.1);
    }

    .mbsc-timeline-header-time {
      text-align: center;
      font-size: 12px;
    }

    .mbsc-ios.mbsc-calendar-button.mbsc-button {
      color: #343741;
      font-weight: 700;
      font-family: 'Inter';
    }

    .mbsc-ios.mbsc-calendar-header,
    .mbsc-ios.mbsc-calendar-wrapper {
      border-color: rgba(19, 34, 149, 0.1);
      padding-bottom: 5px;
    }

    .mbsc-ios.mbsc-eventcalendar .mbsc-calendar-wrapper {
      border-color: rgba(19, 34, 149, 0.1);
      padding-bottom: 8px;
    }

    .mbsc-ios.mbsc-schedule-time-indicator {
      border-color: #0077cc;
    }
    .mbsc-schedule-time-indicator-y {
      border-left: 3px solid;
    }

    .mbsc-timeline {
      z-index: 0;
    }
  }
`;

export const MedEventcalendar = StyledMedEventcalendar;
