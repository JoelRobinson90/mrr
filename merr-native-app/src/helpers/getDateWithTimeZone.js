import { getCalendars } from 'expo-localization';
import { replace, isEmpty } from 'lodash';
import moment from 'moment-timezone';
import { sentryCaptureException } from '../service/sentry';

const momentize = (date, zone) => (isEmpty(zone) ? moment(date) : moment.tz(date, zone));

const formatDate = (date, format, zone) => momentize(date, zone).format(format);

const getDateWithTimeZone = (
  time,
  formatText,
  externalTimeZone = null,
) => {
  try {
    const calendarTimeZone = getCalendars() && getCalendars()[0] ? getCalendars()[0].timeZone : '';
    const timeZone = externalTimeZone ? replace(externalTimeZone, ' ', '_') : calendarTimeZone;
    let timeTransform = null;
    if (time?.toString()?.includes(' UTC')) {
      timeTransform = replace(time, ' UTC', 'Z');
      timeTransform = replace(timeTransform, ' ', 'T');
    } else {
      timeTransform = new Date(time);
    }
    return formatDate(timeTransform, formatText, timeZone);
  } catch (error) {
    sentryCaptureException(error);
    return formatDate(time, formatText);
  }
};

export default getDateWithTimeZone;
