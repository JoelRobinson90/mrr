import {
  AlayacareStatusBgMap,
  AlayacareStatuses,
  AlayacareStatusForegroundMap,
  AlayacareVisit,
  DriveTimeCalendarEvent,
  FieldProviderResource,
  ScheduleEventType,
  StatusBgMap,
  StatusForegroundMap,
  VisitCalendarEvent,
} from '@/common/types';
import { compact, each, groupBy, uniq } from 'lodash';
import moment from 'moment';
import { formatUtc } from '../dates/dates';
import { formatDate, SHORT_DATE_FORMAT, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { filter } from 'lodash';
import { MbscCalendarEvent } from '@mobiscroll/react';

export const formatVisitAsEvent = (visit, extraFields = {}) => {
  return {
    startDate: moment(visit.start_time).toDate(),
    start: formatUtc(moment(visit.start_time)),
    end: formatUtc(moment(visit.end_time)),
    start_time: formatUtc(moment(visit.start_time)),
    endDate: moment(visit.end_time).toDate(),
    end_time: formatUtc(moment(visit.end_time)),
    cx_start: formatUtc(moment(visit.cx_start)),
    cx_end: formatUtc(moment(visit.cx_end)),
    resource: visit.fp_id,
    location: visit.location,
    patient: visit.patient,
    visit_type: visit.visit_type,
    status: visit.status,
    demand_partner: visit.demand_partner,
    alayacare_visit_id: visit.alayacare_visit_id,
    visit_id: visit.visit_id,
    fp_name: visit.fp_name,
    notes: visit.notes,
    services: visit.services,
    drive_time: visit.drive_time,
    ...extraFields,
  };
};

export const filterShiftsByDemandPartner = (
  shifts: FieldProviderResource[],
  selectedDemandPartners: { label: string }[],
  visits: AlayacareVisit[],
) => {
  let fps = shifts;
  if (selectedDemandPartners?.length) {
    const filteredVisits = visits.filter((v) => {
      if (!v.demand_partner) {
        return false;
      }

      return selectedDemandPartners?.map((dp) => dp.label).includes(v.demand_partner?.name);
    });
    const fpIds: string[] = compact(uniq(filteredVisits.map((v) => v.fp_id)));

    fps = fps.filter((fp) => fpIds.includes(`${fp.id}`));
    fps = fps.filter((fp) => fp.groups.includes(selectedDemandPartners[0].label));
  }
  return fps;
};

export const filterVisitsByDemandPartner = (
  visits: VisitCalendarEvent[] & DriveTimeCalendarEvent[],
  selectedDemandPartners: { label: string }[],
) => {
  let slots = visits;
  if (selectedDemandPartners?.length) {
    slots = slots.filter((v) => {
      if (!v.demand_partner) {
        return false;
      }

      return selectedDemandPartners?.map((dp) => dp.label).includes(v.demand_partner?.name);
    });
  }
  return slots;
};

export const removeSystemCancellationsFromVisits = (visits = []) => {
  return visits?.filter(function (v) {
    return v.cancel_code?.code !== 'SYSTEM CANCELATION - DO NOT USE';
  });
};

const generateDriveTimes = (visitSlots) => {
  const driveTimeSlots = [];
  const visitsByFieldProvider = groupBy(visitSlots, 'fp_id');

  each(visitsByFieldProvider, (visits) => {
    each(visits, (visit, index) => {
      // if no drive time or the visit is cancelled then skip rendering drive time
      if (!visit.drive_time || visit.drive_time === 0 || visit.cancelled || visit.cancel_code) return;

      const driveTimeStart = moment(visit.start_time).subtract(visit.drive_time, 'minutes');
      const driveTimeEnd = moment(visit.start_time);
      const previousVisit = index !== 0 ? visits[index - 1] : null;

      // skip if there's a previous visit with same start time
      if (previousVisit && moment(previousVisit.end_time).isSame(moment(visit.start_time))) return;

      // render drive time if first visit or if drive time doesn't collides with previous visit
      if (index === 0 || driveTimeStart.isAfter(moment(previousVisit.end_time))) {
        driveTimeSlots.push(
          formatVisitAsEvent(visit, {
            title: `${visit.drive_time} min`,
            eventType: ScheduleEventType.DRIVE,
            start: formatUtc(driveTimeStart),
            end: formatUtc(driveTimeEnd),
          }),
        );
      }
    });
  });
  return driveTimeSlots;
};

export const formatVisitDataForCalendar = (
  visits,
  { includeDriveTimeSlots = false, ScheduleEventType = null, selectedDemandPartner = null, visitUpdates = {} }, displaySecondaryResourceVisits = false
) => {
  let slots: VisitCalendarEvent[] & DriveTimeCalendarEvent[];

  // To show the same visit on the calendar for multiple resources, we need to duplicate the data
  // and tweak it to look like how we need it for each resource
  let dupVisitsForResources = []
  if (displaySecondaryResourceVisits) {
    visits.forEach((v) => {
      if (v?.resources?.length > 0) {
        return v?.resources.forEach((resource) => {
          if (v.fp_id !== resource.fp_external_id) {
            dupVisitsForResources.push({
              ...v,
              fp_id: resource.fp_external_id,
              end_time: resource.end_time,
              start_time: resource.start_time,
              cx_start: resource.start_time,
              cx_end: resource.end_time
            })
          }
        })
      }
    })
  }


  const visitSlots = visits.concat(dupVisitsForResources).map((visit) => {
    const visitTime = formatDate(visit.start_time.toString(), TIME_FORMAT_WITH_ZONE, visit?.patient?.address?.timezone);

    const title = visit.patient ? `${visitTime} - ${visit.patient.first_name} ${visit.patient.last_name}` : 'Visit';
    const date = formatDate(visit.start_time.toString(), SHORT_DATE_FORMAT);
    let formattedVisit = formatVisitAsEvent(visit, {
      ...visit,
      title,
      eventType: ScheduleEventType?.VISIT,
      visit_id: visit.visit_id || visit.alayacare_visit_id,
      fullDay: filter(visits, (v) => date === formatDate(v.start_time.toString(), SHORT_DATE_FORMAT))?.length === 1,
    });

    if (Object.keys(visitUpdates).includes(`${formattedVisit.visit_id}`)) {
      const updatedFields = visitUpdates[formattedVisit.visit_id];

      formattedVisit = {
        ...formattedVisit,
        ...updatedFields,
      };
    }

    return formattedVisit;
  });

  slots = [...visitSlots];

  if (includeDriveTimeSlots) {
    const driveTimeSlots = generateDriveTimes(visitSlots);
    slots = [...visitSlots, ...driveTimeSlots];
  }

  slots = selectedDemandPartner ? filterVisitsByDemandPartner(slots, selectedDemandPartner) : slots;
  return slots;
};

export const calculateInfoColor = (visit: MbscCalendarEvent) => {
  const isProgramV2 = visit?.program?.v2;
  let status = visit?.status;
  if (visit?.confirmed && visit?.status === 'scheduled') status = AlayacareStatuses.confirmed;

  const text = isProgramV2
    ? StatusForegroundMap[status] || AlayacareStatusForegroundMap[AlayacareStatuses.completed]
    : AlayacareStatusForegroundMap[status] || AlayacareStatusForegroundMap[AlayacareStatuses.completed];

  const backgroundColor = isProgramV2
    ? StatusBgMap[status] || AlayacareStatusBgMap[AlayacareStatuses.completed]
    : AlayacareStatusBgMap[status] || AlayacareStatusBgMap[AlayacareStatuses.completed];

  return {
    text,
    backgroundColor,
  };
};
