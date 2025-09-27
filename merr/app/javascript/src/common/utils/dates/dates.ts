import { isEmpty } from 'lodash';
import moment from 'moment-timezone';
import { Appointment } from '@/common/types';

// YYYY-MM-DD
export const DASH_DATE_REGEX = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;

// MM/DD/YYYY
export const SLASH_DATE_REGEX = /^(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])\/\d{4}$/;

// MM/DD/YYYY => YYYY-MM-DD
export const slashDateToDashDate = (s?: string): string => {
  if (isEmpty(s)) return '';
  const year = s.substr(6, 4);
  const day = s.substr(3, 2);
  const month = s.substr(0, 2);
  return `${year}-${month}-${day}`;
};

// YYYY-MM-DD => MM/DD/YYYY
export const dashDateToSlashDate = (s?: string): string => {
  if (isEmpty(s)) return '';
  const year = s.substr(0, 4);
  const month = s.substr(5, 2);
  const day = s.substr(8, 2);
  return `${month}/${day}/${year}`;
};

export const timeSince = (dischargeDate: moment.Moment | Date | string): string => {
  const latestCheckDate = moment(dischargeDate).add(72, 'hours');
  const difference = Math.abs(moment().diff(latestCheckDate));
  const seconds = difference / 1000;
  const minutes = seconds / 60;
  const hours = minutes / 60;

  let hoursRemaining = '';
  let minutesRemaining = '';
  let timeRemaining = '';

  hoursRemaining += Math.floor(hours) + ' hrs ';
  minutesRemaining += Math.floor(minutes % 60) + ' min left';
  timeRemaining = hoursRemaining + minutesRemaining;

  return timeRemaining;
};

type Datelike = moment.Moment | Date | string;

export const momentize = (date: Datelike, zone?: string): moment.Moment =>
  isEmpty(zone) ? moment(date) : moment.tz(date, zone);

export const formatDate = (date: Datelike, format: string, zone?: string): string =>
  momentize(date, zone).format(format);

export const parseDate = (dateString: string, format?: string): moment.Moment => moment(dateString, format);

export const getTimezoneLabel = (zone?: string): string => {
  const momentized = isEmpty(zone) ? moment() : moment.tz(zone);
  return momentized.format('z');
};

export const formatUtc = (date: Datelike): string => momentize(date).utc().format();

// 1987-03-13
export const DB_DATE_FORMAT = 'YYYY-MM-DD';

// 3/13/1987
export const SHORT_DATE_FORMAT = 'M/DD/YYYY';

// Tu, 4/12/2022
export const SHORT_DATE_AND_WEEKDAY_FORMAT = 'dd M/DD/YYYY';

// March 13, 1987
export const LONG_DATE_FORMAT = 'dddd, MMMM Do, YYYY';

// Friday, March 13, 1987
export const DATE_WITH_DAY = 'dddd, MMMM Do';

// March 13th 2022, 8:00am
export const DATE_WITH_TIME = 'MMMM Do YYYY, h:mma';

// 8:00am
export const TIME_FORMAT = 'h:mma';

// 8:00 AM
export const TIME_FORMAT_NO_M = 'h:mm A';

// 8:00am PST
export const TIME_FORMAT_WITH_ZONE = 'h:mma z';

// 8:00am PST
export const TIME_FORMAT_WITH_ZONE_NO_AM = 'h:mm z';

// 8am or 8:30am
export const SHORT_TIME_FORMAT = 'h:mma'.replace(/:00/g, '');

// 8:00
export const TIME_FORMAT_NO_AM = 'h:mm';

// PST
export const TIME_ZONE_ONLY = 'z';

export const formatShortTimerange = (from: Datelike, to: Datelike): string =>
  `${formatDate(from, TIME_FORMAT_NO_M)}-${formatDate(to, TIME_FORMAT)}`.replace(/:00/g, '');

export const appointmentDisplayDate = (appointment: Appointment): string => {
  const { start_time, address } = appointment;
  const { timezone } = address || {};
  if (start_time) {
    return `${formatDate(start_time, SHORT_DATE_FORMAT, timezone)}`;
  }
  return 'No time set';
};

export const appointmentDisplayTime = (appointment: Appointment): string => {
  const { start_time, end_time, address } = appointment;
  const { timezone } = address || {};
  if (start_time && end_time) {
    return `${formatDate(start_time, TIME_FORMAT, timezone)} - ${formatDate(
      end_time,
      TIME_FORMAT_WITH_ZONE,
      timezone,
    )}`;
  } else if (start_time) {
    return `${formatDate(start_time, TIME_FORMAT_WITH_ZONE, timezone)}`;
  }
  return '';
};

export const appointmentDisplayDateTime = (appointment: Appointment): string => {
  const time = appointmentDisplayTime(appointment);
  return appointmentDisplayDate(appointment) + (time ? ` @ ${time}` : '');
};
