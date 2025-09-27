import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { MbscCalendarEventData, MbscResource, momentTimezone } from '@mobiscroll/react';
import React, { useMemo } from 'react';
import { map } from 'lodash';
import { MbscCalendarColor } from '@mobiscroll/react/dist/src/core/shared/calendar-view/calendar-view';
import moment from 'moment-timezone';
import { formatUtc, formatDate, DB_DATE_FORMAT } from '@/common/utils/dates/dates';
import { EuiPageHeader, EuiPageHeaderSection, EuiPanel, EuiTitle } from '@elastic/eui';
import { admin_alayacare_field_providers_path } from '@/common/routes';
import {
  DataByFieldProvider,
  FieldProviderShift,
  getShiftColors,
  getUnavailabilityColors,
  sortDataByFp,
} from './SchedulerUtils';

momentTimezone.moment = moment;

type AlayacareAppointment = {
  fp_id: string;
  location: string;
  start_time: string;
  end_time: string;
};

type FieldProviderSchedulesPageProps = AdminPageProps & {
  shifts: FieldProviderShift[];
  appointments: AlayacareAppointment[];
  start_date: string;
  end_date: string;
};

const shiftId = (shift: FieldProviderShift): string => `${shift.fp_id}-${shift.start_time}`;
const apptId = (appt: AlayacareAppointment): string => `${appt.fp_id}-${appt.start_time}`;

export const FieldProviderSchedulesPage: React.FC<FieldProviderSchedulesPageProps> = ({
  shifts,
  appointments,
  start_date,
  end_date,
  layout_props,
}) => {
  const shiftsCacheKey = shifts.map(shiftId).join();
  const appointmentsCacheKey = appointments.map(apptId).join();

  const startOfCalendar = useMemo(() => moment(start_date).startOf('day'), [start_date]);
  const endOfCalendar = useMemo(() => moment(end_date).endOf('day'), [end_date]);

  const dataByFp: DataByFieldProvider = useMemo(() => sortDataByFp(shifts, appointments), [
    shiftsCacheKey,
    appointmentsCacheKey,
  ]);

  const availabilityColors: MbscCalendarColor[] = useMemo(
    () => [...getShiftColors(dataByFp), ...getUnavailabilityColors(dataByFp, startOfCalendar, endOfCalendar)],
    [shiftsCacheKey, appointmentsCacheKey],
  );

  const calendarResources: MbscResource[] = useMemo(() => {
    return map(dataByFp, ({ shifts }, fp_id) => ({
      id: fp_id,
      name: shifts.length ? shifts[0].fp_name : `ID: ${fp_id}`,
    }));
  }, [shiftsCacheKey, appointmentsCacheKey]);

  const calendarEvents: MbscCalendarEventData[] = useMemo(() => {
    return appointments.map((appt) => ({
      startDate: moment(appt.start_time).toDate(),
      start: formatUtc(moment(appt.start_time)),
      endDate: moment(appt.end_time).toDate(),
      end: formatUtc(moment(appt.end_time)),
      color: '#FFCCCC',
      title: 'Appointment',
      resource: appt.fp_id,
      location: appt.location,
    }));
  }, [appointmentsCacheKey]);

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <span>Daily Schedule</span>
          </EuiTitle>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPanel>
        <MedEventcalendar
          view={{
            timeline: {
              type: 'day',
              startDay: startOfCalendar.day(),
            },
          }}
          resources={calendarResources}
          colors={availabilityColors}
          data={calendarEvents}
          dataTimezone="utc"
          timezonePlugin={momentTimezone}
          onPageChange={(day) => {
            const newDate = formatDate(day.firstDay, DB_DATE_FORMAT);
            window.location.assign(admin_alayacare_field_providers_path({ date: newDate }));
          }}
        />
      </EuiPanel>
    </AdminLayout>
  );
};
