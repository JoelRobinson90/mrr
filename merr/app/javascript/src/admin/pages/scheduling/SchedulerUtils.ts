import moment from 'moment';

export const apptId = (appt: any): string => `${appt.fp_id}-${moment(appt.start_time).utc().format()}`;

// builds mobiscroll event object for calendar
export const eventFormatter = (visit) => {
  const title = !visit.fp_id ? 'Invalid: Missing Setup' : visit.fp_name;
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
    rank_category: visit.rank_category,
    total_score: visit.total_score,
    arrival_window_start: visit.arrival_window_start,
    arrival_window_end: visit.arrival_window_end,
    resources: visit?.resources,
  };
};

export const VISIT_RANK_CATEGORIES = {
  BEST: 'high',
  AVERAGE: 'medium',
  WORST: 'low',
};
