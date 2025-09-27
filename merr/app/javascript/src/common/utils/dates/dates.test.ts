import {
  dashDateToSlashDate,
  formatDate,
  formatUtc,
  slashDateToDashDate,
  timeSince,
  appointmentDisplayDate,
  appointmentDisplayTime,
  appointmentDisplayDateTime,
  DASH_DATE_REGEX,
  SLASH_DATE_REGEX,
  TIME_FORMAT,
  TIME_FORMAT_WITH_ZONE,
} from './dates';
import timezoneMock from 'timezone-mock';
import { buildAddress, buildAppointment } from '@/../test_utils/factories';

describe('dates utils', () => {
  // Mock timezone for all tests
  beforeAll(() => {
    timezoneMock.register('US/Eastern');
  });

  afterAll(() => {
    timezoneMock.unregister();
  });

  describe('DASH_DATE_REGEX', () => {
    it('matches valid YYYY-MM-DD dates', () => {
      expect('1987-03-13'.match(DASH_DATE_REGEX)).toBeTruthy();
      expect('2050-06-20'.match(DASH_DATE_REGEX)).toBeTruthy();
      expect('1800-07-04'.match(DASH_DATE_REGEX)).toBeTruthy();
    });

    it('does not match invalid YYYY-MM-DD dates', () => {
      expect('198-03-13'.match(DASH_DATE_REGEX)).toBeFalsy();
      expect('1987-13-03'.match(DASH_DATE_REGEX)).toBeFalsy();
      expect('1987-03-33'.match(DASH_DATE_REGEX)).toBeFalsy();
      expect('1987-00-13'.match(DASH_DATE_REGEX)).toBeFalsy();
      expect('1987-03-00'.match(DASH_DATE_REGEX)).toBeFalsy();
      expect('03/13/1987'.match(DASH_DATE_REGEX)).toBeFalsy();
    });
  });

  describe('SLASH_DATE_REGEX', () => {
    it('matches valid MM/DD/YYYY dates', () => {
      expect('03/13/1987'.match(SLASH_DATE_REGEX)).toBeTruthy();
      expect('06/20/2050'.match(SLASH_DATE_REGEX)).toBeTruthy();
      expect('07/04/1800'.match(SLASH_DATE_REGEX)).toBeTruthy();
    });

    it('does not match invalid DD/MM/YYYY dates', () => {
      expect('03/13/198'.match(SLASH_DATE_REGEX)).toBeFalsy();
      expect('13/03/1987'.match(SLASH_DATE_REGEX)).toBeFalsy();
      expect('03/33/1987'.match(SLASH_DATE_REGEX)).toBeFalsy();
      expect('00/13/1987'.match(SLASH_DATE_REGEX)).toBeFalsy();
      expect('03/00/1987'.match(SLASH_DATE_REGEX)).toBeFalsy();
      expect('1987-03-13'.match(SLASH_DATE_REGEX)).toBeFalsy();
    });
  });

  describe('slashDateToDashDate()', () => {
    it('naively attempts to convert MM/DD/YYYY dates to YYYY-MM-DD dates', () => {
      expect(slashDateToDashDate('03/13/1987')).toEqual('1987-03-13');

      // emulates incomplete masked input
      expect(slashDateToDashDate('03/13/19__')).toEqual('19__-03-13');
      expect(slashDateToDashDate('__/__/____')).toEqual('____-__-__');
    });

    it('does not attempt to convert empty values', () => {
      expect(slashDateToDashDate(null)).toEqual('');
      expect(slashDateToDashDate(undefined)).toEqual('');
      expect(slashDateToDashDate('')).toEqual('');
    });
  });

  describe('dashDateToSlashDate()', () => {
    it('naively attempts to convert YYYY-MM-DD dates to MM/DD/YYYY dates', () => {
      expect(dashDateToSlashDate('1987-03-13')).toEqual('03/13/1987');
    });

    it('does not attempt to convert empty values', () => {
      expect(dashDateToSlashDate(null)).toEqual('');
      expect(dashDateToSlashDate(undefined)).toEqual('');
      expect(dashDateToSlashDate('')).toEqual('');
    });
  });

  describe('timeSince()', () => {
    beforeAll(() => {
      // lock time
      jest.spyOn(Date, 'now').mockImplementation(() => 1617120000000);
    });

    afterAll(() => {
      // unlock time
      jest.spyOn(Date, 'now').mockRestore();
    });

    it('attempts to extract Years, Months, Days, Hours, Minutes, Seconds for', () => {
      expect(timeSince(new Date(1617033600000))).toEqual('48 hrs 0 min left');
      expect(timeSince(new Date(1617033660000))).toEqual('48 hrs 1 min left');
      expect(timeSince(new Date(1617033540000))).toEqual('47 hrs 59 min left');
    });
  });

  describe('formatUtc()', () => {
    it('formats a date to utc to store and send back to API', () => {
      const initDate = '2021-06-14T11:12:40-04:00';
      expect(formatUtc(initDate)).toEqual('2021-06-14T15:12:40Z');
    });
  });

  describe('appointmentDisplayDate()', () => {
    it('displays start date in the appointment timezone', () => {
      const appointment = buildAppointment({
        // Purposely 7/5 in UTC but 7/4 in Pacific
        start_time: '2021-07-05T01:00:00.000Z',
        address: buildAddress({
          timezone: 'America/Los_Angeles',
        }),
      });

      expect(appointmentDisplayDate(appointment)).toEqual('7/04/2021');
    });
  });

  describe('appointmentDisplayTime()', () => {
    it('returns start and end time with appointment timezone', () => {
      const appointment = buildAppointment({
        start_time: '2021-07-05T01:00:00.000Z',
        end_time: '2021-07-05T03:00:00.000Z',
      });

      expect(appointmentDisplayTime(appointment)).toEqual('6:00pm - 8:00pm PDT');
    });

    it('returns only start time if there is no end time', () => {
      const appointment = buildAppointment({
        start_time: '2021-07-05T01:00:00.000Z',
        end_time: null,
      });

      expect(appointmentDisplayTime(appointment)).toEqual('6:00pm PDT');
    });
  });

  describe('appointmentDisplayDateTime()', () => {
    it('return date and time range with appointment timezone', () => {
      const appointment = buildAppointment({
        start_time: '2021-07-05T01:00:00.000Z',
        end_time: '2021-07-05T03:00:00.000Z',
      });

      expect(appointmentDisplayDateTime(appointment)).toEqual('7/04/2021 @ 6:00pm - 8:00pm PDT');
    });

    it('returns date and start time only if there is no end_time', () => {
      const appointment = buildAppointment({
        start_time: '2021-07-05T01:00:00.000Z',
        end_time: null,
      });

      expect(appointmentDisplayDateTime(appointment)).toEqual('7/04/2021 @ 6:00pm PDT');
    });

  });

  describe('formatDate()', () => {
    describe('without timezone', () => {
      it("returns a formatted time in the browser's timezone", () => {
        const time = '2021-05-10T23:23:51.735Z';
        expect(formatDate(time, TIME_FORMAT)).toEqual('7:23pm');
      });
    });
    describe('with zone', () => {
      it('returns a formatted time with proper timezone abbreviaton', () => {
        const time = '2021-05-10T23:23:51.735Z';
        const zone = 'America/Los_Angeles';
        expect(formatDate(time, TIME_FORMAT_WITH_ZONE, zone)).toEqual('4:23pm PDT');

        const time2 = '2021-12-10T23:23:51.735Z';
        expect(formatDate(time2, TIME_FORMAT_WITH_ZONE, zone)).toEqual('3:23pm PST');
      });
    });
  });
});
