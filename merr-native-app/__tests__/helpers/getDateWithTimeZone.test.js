import moment from 'moment-timezone';
import { getCalendars } from 'expo-localization';
import getDateWithTimeZone from '../../src/helpers/getDateWithTimeZone';

moment.tz.setDefault('America/New_York');
jest.mock('expo-localization');

describe('getDateWithTimeZone', () => {
  const formatText = 'YYYY-MM-DDTHH:mm:ssZ';
  const externalTimeZone = 'America/New_York';
  const time = '2023-04-10 17:00:00 UTC';

  it('converts UTC time to local time with specified format', () => {
    const expectedOutput = '2023-04-10T13:00:00-04:00';

    expect(getDateWithTimeZone(time, formatText, externalTimeZone)).toEqual(expectedOutput);
  });

  it('returns local time with specified format when no external timezone is provided', () => {
    getCalendars.mockReturnValueOnce([{ timeZone: externalTimeZone }]);
    const expectedOutput = moment.tz(time, externalTimeZone).format(formatText);

    expect(getDateWithTimeZone(time, formatText)).toEqual(expectedOutput);
  });

  it('returns local time without specified format', () => {
    getCalendars.mockReturnValueOnce(null);
    const expectedOutput = moment.tz(time, externalTimeZone).format(formatText);

    expect(getDateWithTimeZone(time, formatText)).toEqual(expectedOutput);
  });
});
