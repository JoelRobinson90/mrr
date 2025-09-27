import { FieldProvider } from '@/common/types';
import { formatUtc } from '@/common/utils/dates/dates';
import { MbscCalendarColor } from '@mobiscroll/react/dist/src/core/shared/calendar-view/calendar-view';
import { each, sortBy } from 'lodash';
import moment from 'moment';

const UNAVAILABLE_COLOR = 'rgba(250, 251, 253, 1)';
const AVAILABLE_COLOR = '#FFFFFF';

export type FieldProviderShift = {
  fp_id: string;
  start_time: string;
  end_time: string;
  fp_name: string;
  groups: string[];
  location: string;
  not_working?: boolean;
  provider_role: string;
  providers: FieldProvider[];
};

export type DataByFieldProvider = {
  [fp_id: string]: { shifts: FieldProviderShift[]; appointments: AlayacareAppointment[] };
};

type AlayacareAppointment = {
  fp_id: string;
  location: string;
  start_time: string;
  end_time: string;
};

export const sortDataByFp = (
  shifts: FieldProviderShift[],
  appointments: AlayacareAppointment[],
): DataByFieldProvider => {
  const shortedShifts = sortBy(shifts, 'start_time');
  const sortedAppts = sortBy(appointments, 'start_time');

  const data: DataByFieldProvider = {};
  const setDataKey = (key: string) => (data[key] = data[key] || { shifts: [], appointments: [] });

  shortedShifts.forEach((shift) => {
    setDataKey(shift.fp_id);
    data[shift.fp_id].shifts.push(shift);
  });
  sortedAppts.forEach((appt) => {
    setDataKey(appt.fp_id);
    data[appt.fp_id].appointments.push(appt);
  });

  return data;
};

export const getUnavailabilityColors = (
  data: DataByFieldProvider,
  rangeStart: moment.Moment,
  rangeEnd: moment.Moment,
): MbscCalendarColor[] => {
  const unavailabilities: MbscCalendarColor[] = [];
  each(data, ({ shifts }, fp_id) => {
    // If no shifts, mark all as unavailable
    if (shifts.length === 0) {
      unavailabilities.push({
        id: `unavail-${fp_id}-${formatUtc(rangeStart)}`,
        start: moment(rangeStart).add(1, 'h').toDate(),
        end: rangeEnd.toDate(),
        background: UNAVAILABLE_COLOR,
        invalid: true,
        resource: fp_id,
      });
      return;
    }

    // Make an unavailability range before each shift
    shifts.forEach(({ start_time }, i) => {
      const start = i === 0 ? rangeStart : moment(shifts[i - 1].end_time);
      const end = moment(start_time);
      if (end.isAfter(start)) {
        unavailabilities.push({
          id: `unavail-${fp_id}-${formatUtc(start)}`,
          start: start.toDate(),
          end: end.toDate(),
          background: UNAVAILABLE_COLOR,
          invalid: true,
          resource: fp_id,
        });
      }
    });

    // Make one more unavailability range at the end of the calendar range
    const lastShift = shifts[shifts.length - 1];
    const lastShiftEnd = moment(lastShift.end_time);
    if (rangeEnd.isAfter(lastShiftEnd)) {
      unavailabilities.push({
        id: `unavail-${fp_id}-${formatUtc(lastShiftEnd)}`,
        start: lastShiftEnd.toDate(),
        end: rangeEnd.toDate(),
        background: UNAVAILABLE_COLOR,
        invalid: true,
        resource: fp_id,
      });
    }
  });
  return unavailabilities;
};

export const getShiftColors = (data: DataByFieldProvider, availableColor?: string): MbscCalendarColor[] => {
  const availabilities: MbscCalendarColor[] = [];
  each(data, ({ shifts }, fp_id) => {
    shifts.forEach(({ start_time, end_time }) => {
      availabilities.push({
        id: `shift-${fp_id}-${formatUtc(start_time)}`,
        start: moment(start_time).toDate(),
        end: moment(end_time).toDate(),
        background: availableColor || AVAILABLE_COLOR,
        invalid: false,
        resource: fp_id,
      });
    });
  });
  return availabilities;
};

export const shiftId = (shift: FieldProviderShift): string => `${shift.fp_id}-${shift.start_time}`;
export const apptId = (appt: AlayacareAppointment): string => `${appt.fp_id}-${moment(appt.start_time).utc().format()}`;

export const checkVisitDate = (visitDate) => {
  const now = new Date();
  const eventDate = moment(visitDate);
  return eventDate.isSame(now, 'day') || eventDate < moment(now);
};

// builds mobiscroll event object for calendar
export const eventFormatter = (visit) => {
  const title = !visit.fp_id ? 'Invalid: Missing Setup' : `${visit.rank} - ${visit.fp_name}`;
  return {
    startDate: moment(visit.start_time).toDate(),
    start: moment(visit.cx_start).format(),
    start_time: moment(visit.start_time).format(),
    endDate: moment(visit.end_time).toDate(),
    end: moment(visit.cx_end).format(),
    title,
    id: visit.id,
    resource: visit.fp_id,
    fp_id: visit.fp_id,
    location: visit.location,
    rank: visit.rank,
  };
};
