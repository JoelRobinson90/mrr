import React, { FC, useCallback, useEffect, useMemo, useState } from 'react';
import {
  EuiTitle,
  EuiPageContent,
  EuiPageContentHeader,
  EuiSpacer,
  EuiFlexItem,
  EuiGlobalToastList,
  EuiAvatar,
  EuiText,
  EuiBadge,
} from '@elastic/eui';
import { AdminPageProps, withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { MbscEventcalendarView, momentTimezone } from '@mobiscroll/react';
import moment from 'moment';
import { compact, findIndex, flatten, map, startCase, uniq, uniqBy } from 'lodash';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { DB_DATE_FORMAT, formatDate, TIME_FORMAT_NO_AM, TIME_FORMAT_WITH_ZONE_NO_AM } from '@/common/utils/dates/dates';
import { MbscCalendarColor } from '@mobiscroll/react/dist/src/core/shared/calendar-view/calendar-view';
import {
  DataByFieldProvider,
  FieldProviderShift,
  getShiftColors,
  getUnavailabilityColors,
  sortDataByFp,
} from '../../alayacare/SchedulerUtils';
import {
  admin_capacity_availability_path,
  admin_capacity_get_availability_by_date_path,
  edit_visit_partial_admin_patient_path,
  field_capacity_get_availability_by_date_path,
  edit_visit_partial_field_patient_path,
} from '@/common/routes';
import { CalendarPopup } from '../components/CalendarPopup';
import {
  AlayacareVisit,
  DriveTimeCalendarEvent,
  ScheduleEventType,
  VisitCalendarEvent,
  FieldProviderResource,
} from '@/common/types';
import { DriveTimeSlot } from '../components/CalendarDriveTimeSlot';
import { PatientVisitEvent } from '@/common/components/Calendar/PatientVisitEvent/PatientVisitEvent';
import { VisitPopup } from '@/common/components/Calendar/VisitPopup/VisitPopup';
import { MedFlyout } from '@/common/components/MedFlyout/MedFlyout';
import { RemotePartial } from '@/common/components/RemotePartial/RemotePartial';
import { VisitStatusKey } from '@/common/components/VisitStatusKey/VisitStatusKey';
import { filterShiftsByDemandPartner } from '@/common/utils/calendar/utils';
import { formatVisitDataForCalendar, removeSystemCancellationsFromVisits } from '@/common/utils/calendar/utils';
import { useEffectSkipFirst } from '@/common/hooks/useEffectSkipFirst/useEffectSkipFirst';
import { ScheduleFilters } from '../components/ScheduleFilters';
import ScheduleCalendarHeader, {
  SCHEDULE_CALENDAR_DATE_FILTER_KEY,
  SCHEDULE_CALENDAR_VIEW_FILTER_KEY,
} from '../components/ScheduleCalendarHeader';
import useFilters, { FILTERS_SCHEDULE_FILTER_ID } from '@/common/hooks/useFilters/useFilters';

momentTimezone.moment = moment;

const SHIFT_COLOR = '#B7CDE5';

export const DRIVE_TIME_EVENT_TYPE = 'drive';

interface CapacityPageProps extends AdminPageProps {
  current_user: any;
}

const shiftId = (shift: FieldProviderShift): string => `${shift.fp_id}-${shift.start_time}`;
const apptId = (appt: AlayacareVisit): string => `${appt.fp_id}-${appt.alayacare_visit_id}`;

type CalendarViewType = 'day' | 'week';

const CapacityPageScreen: FC<CapacityPageProps> = ({ current_user }) => {
  const [shiftCoverageToggle, setShiftCoverageToggle] = useState(true);
  const [onlyShowWorkingToggle, setOnlyShowWorkingToggle] = useState(false);
  const [selectedFieldProvider, setSelectedFieldProvider] = useState([]);
  const [selectedDemandPartner, setSelectedDemandPartner] = useState([]);
  const selectedDemandPartnerCacheKey = selectedDemandPartner?.map((dp) => dp?.label).join();
  const [resources, setResources] = useState([]);
  const [shifts, setShifts] = useState([]);
  const [visits, setVisits] = useState([]);
  const [toasts, setToasts] = useState([]);
  const [visit, setVisit] = useState(null);
  const [visitAnchor, setVisitAnchor] = useState(null);
  const [isOpen, setOpen] = useState(false);
  const timerRef = React.useRef(null);

  const { updateFilter, findFilter } = useFilters();

  const calendarDateCached = useMemo(
    () => findFilter(FILTERS_SCHEDULE_FILTER_ID, SCHEDULE_CALENDAR_DATE_FILTER_KEY),
    [],
  );

  const cachedCalendarView = useMemo(
    () => findFilter(FILTERS_SCHEDULE_FILTER_ID, SCHEDULE_CALENDAR_VIEW_FILTER_KEY),
    [],
  );

  const [view, setView] = useState<CalendarViewType>(
    cachedCalendarView?.value ? (`${cachedCalendarView?.value}` as CalendarViewType) : 'day',
  );

  const [calView, setCalView] = useState<MbscEventcalendarView>({
    timeline:
      view === 'day'
        ? {
            type: view,
            startTime: '04:00',
            endTime: '23:59',
          }
        : {
            type: 'week',
            eventList: true,
          },
  });

  const shiftsCacheKey = shifts.map(shiftId).join();
  const appointmentsCacheKey = [...visits.map(apptId)].join();

  const [startOfCalendar, setStartOfCalendar] = useState(() =>
    calendarDateCached?.value ? moment(calendarDateCached.value) : moment().startOf('day'),
  );
  const [endOfCalendar, setEndOfCalendar] = useState(moment().endOf('day'));

  const dataByFp: DataByFieldProvider = sortDataByFp(shifts, visits);

  const [editFlyoutPath, setEditFlyoutPath] = useState<string | null>(null);
  const [toggleReloadCalendarData, setToggleReloadCalendarData] = useState<boolean>(false);
  const [visitUpdates, setVisitUpdates] = useState({});

  const availabilityColors: MbscCalendarColor[] = useMemo(
    () => [
      ...getShiftColors(dataByFp, SHIFT_COLOR),
      ...getUnavailabilityColors(dataByFp, startOfCalendar, endOfCalendar),
    ],
    [shiftsCacheKey, appointmentsCacheKey],
  );

  const calcName = (shifts, appointments, fp_id) => {
    if (shifts.length) {
      return shifts[0].fp_name;
    } else if (appointments.length) {
      return appointments[0].fp_name;
    }
    return `ID: ${fp_id}`;
  };

  // Data for field providers column on the calendar
  const calendarResources: FieldProviderResource[] = useMemo(() => {
    let fps: FieldProviderResource[] = map(dataByFp, ({ shifts, appointments }, fp_id) => ({
      id: fp_id,
      name: calcName(shifts, appointments, fp_id),
      notWorking: appointments.length == 0 && (shifts.length ? shifts[0].not_working : true),
      groups: shifts.length ? shifts[0].groups : [],
      provider_role: shifts[0]?.provider_role || null,
      providers: shifts[0]?.providers,
    }));

    fps = filterShiftsByDemandPartner(fps, selectedDemandPartner, visits);
    return fps;
  }, [shiftsCacheKey, appointmentsCacheKey, selectedDemandPartnerCacheKey, selectedFieldProvider]);

  // Data for visit slots on the calendar
  const calendarEvents: VisitCalendarEvent[] & DriveTimeCalendarEvent[] = useMemo(() => {
    return formatVisitDataForCalendar(visits, {
      ScheduleEventType,
      selectedDemandPartner,
      includeDriveTimeSlots: view === 'day',
      visitUpdates,
    }, true);
  }, [appointmentsCacheKey, selectedDemandPartnerCacheKey, view, toggleReloadCalendarData]);

  const fieldProviderOptions = useMemo(() => {
    const listProviderOptions = [];

    const createLabel = (name, provider_role) =>
      `${name}${provider_role ? ` (${startCase(provider_role)})` : ' (Field Provider)'}`;

    const ResourcesOnVisitsByExternalId = [];
    calendarEvents.forEach((visit) => {
      visit?.resources?.forEach((resource) => {
        ResourcesOnVisitsByExternalId.push(resource.fp_external_id);
      });
    });

    calendarResources.forEach(({ name, id, provider_role, providers }) => {
      const label = createLabel(name, provider_role);
      listProviderOptions.push({
        label,
        value: id.toString()
      });

      providers?.forEach(({ first_name, last_name, role, external_id: externalId }) => {
        if (calendarEvents.length && ResourcesOnVisitsByExternalId.includes(externalId)) {
          const label = createLabel(`${first_name} ${last_name}`, role);
          listProviderOptions.push({
            label,
            value: externalId.toString(),
            role,
          });
        }
      });
    });

    return uniqBy(listProviderOptions, 'label');
  }, [shiftsCacheKey, appointmentsCacheKey, selectedDemandPartner]);

  const demandPartners = useMemo(() => {
    const localDemandPartners = visits.map((v) => v?.demand_partner?.name);
    const alayacareDemandPartners = flatten(shifts.map((s) => s.groups));
    return compact(uniq(flatten([...alayacareDemandPartners, ...localDemandPartners])));
  }, [shiftsCacheKey, appointmentsCacheKey]);

  const demandPartnerOptions = demandPartners?.map((d) => {
    return {
      label: d,
    };
  });

  // BEGIN useEffect block
  useEffect(() => {
    fetchInitialData();
  }, []);

  useEffect(() => {
    if (calendarResources.length) {
      setResourcesAndFilters();
    }
  }, [shiftsCacheKey, appointmentsCacheKey, selectedFieldProvider, selectedDemandPartner, onlyShowWorkingToggle]);

  useEffectSkipFirst(() => {
    // when switching calendar view (day|week) it should re-fetch data
    let newStartDate = moment();
    if (view === 'week') {
      newStartDate = moment(startOfCalendar).startOf('week');
      setStartOfCalendar(newStartDate);
    } else if (view === 'day') {
      setStartOfCalendar(newStartDate);
    }
    fetchData(newStartDate);
  }, [view]);

  const setResourcesAndFilters = () => {
    let filteredResources = [...calendarResources];
    filteredResources = applyFieldProviderFilter(filteredResources);

    if (onlyShowWorkingToggle) {
      filteredResources = filteredResources.filter((r) => !r.notWorking);
    }
    setResources(filteredResources);
  };
  // END useEffect block

  const fetchInitialData = async () => {
    const startDate = formatDate(startOfCalendar, DB_DATE_FORMAT);
    await fetchData(startDate);
    if (current_user?.account_type === 'FieldProvider') {
      setSelectedFieldProvider([{ label: current_user?.display_name, value: current_user?.external_id, role: current_user?.account?.role }])
    } 
  };

  const applyFieldProviderFilter = (array) => {
    if (current_user?.account_type === 'FieldProvider') {
      array.filter((fp) => selectedFieldProvider.map((fp) => fp.value).includes(`${fp.id}`));
    }
    if (selectedFieldProvider?.length) {
      return array.filter((fp) => selectedFieldProvider.map((fp) => fp.value).includes(`${fp.id}`));
    }
    return array;
  };

  const onChangeFieldProvider = (fieldProviderId) => {
    setSelectedFieldProvider(fieldProviderId);
  };

  const onChangeDemandPartner = (demandPartnerName) => {
    setSelectedDemandPartner(demandPartnerName);
  };

  const addToast = (title, text) => {
    const id = `toast-${toasts.length + 1}`;
    const newToast = {
      id,
      title,
      text,
    };
    setToasts((currentToasts) => [...currentToasts, newToast]);
    return id;
  };

  const removeToast = (id) => setToasts((currentToasts) => currentToasts.filter((toast) => toast.id !== id));

  const fetchData = useCallback(
    async (startDate) => {
      const toastId = addToast('Loading, please wait ...', '');
      setShifts([]);
      setVisits([]);
      setResources([]);

      let newStartDate = moment(startDate).format();
      let endDate = moment(newStartDate).endOf('day').format();

      if (view === 'week') {
        newStartDate = moment(startDate).startOf('week').format();
        endDate = moment(newStartDate).endOf('week').format();
        setStartOfCalendar(moment(newStartDate));
      }

      setEndOfCalendar(moment(endDate));

      endDate = formatDate(endDate, DB_DATE_FORMAT);
      newStartDate = formatDate(newStartDate, DB_DATE_FORMAT);

      let response;
      if (current_user?.account_type === 'FieldProvider') {
        response = await fetch(
          field_capacity_get_availability_by_date_path({
            start_date: newStartDate,
            end_date: endDate,
            include_shifts: true,
          }),
        );
      } else {
        response = await fetch(
          admin_capacity_get_availability_by_date_path({
            start_date: newStartDate,
            end_date: endDate,
            include_shifts: true,
          }),
        );
      }

      if (response.status === 200) {
        const jsonResponse = await response.json();
        if (!jsonResponse?.shifts && !jsonResponse?.visits) {
          return;
        }
        const { shifts: newShifts, visits: newVisits, error_message: errorMsg } = jsonResponse;
        setShifts(newShifts);
        setVisits(removeSystemCancellationsFromVisits(newVisits));
        removeToast(toastId);
        if (errorMsg) {
          addToast('Error:', errorMsg);
        }
      } else {
        addToast('There was an error when loading data.', 'Please try again.');
      }
    },
    [view],
  );

  const filterCalendarEvents = useMemo(() => {
    const checkSelectedFpAgainstResources = (visit) => {
      const fpIds = selectedFieldProvider.map((fp) => fp.value);
      let filteredVisit = null;
      if (visit.resources) {
        visit.resources.forEach((resource) => {
          if (fpIds.includes(resource.fp_external_id)) {
            filteredVisit = visit;
          }
        });
      }
      return filteredVisit;
    };

    const newVisits = [];
    if (selectedFieldProvider.length) {
      const filterVisitsByFieldProvider = () =>
        calendarEvents.forEach((visit) => {
          const applicableVisit = checkSelectedFpAgainstResources(visit);
          if (applicableVisit) {
            newVisits.push(applicableVisit);
          }
        });
      filterVisitsByFieldProvider();
    }
    return newVisits.length ? newVisits : calendarEvents;
  }, [selectedFieldProvider, calendarEvents]);

  const renderScheduleEvent = (event) => {
    const { original } = event;
    if (original.eventType === DRIVE_TIME_EVENT_TYPE) {
      return <DriveTimeSlot event={event} />;
    }

    const currentVisit = event?.original;
    const extraContent = currentVisit?.cancelled ? (
      <EuiText style={{ color: '#3d3d3d', fontSize: '12px' }}>
        {typeof currentVisit.cancel_code === 'string' ? currentVisit.cancel_code : currentVisit?.cancel_code?.code}
        <EuiText
          style={{
            fontSize: '11px',
            color: '#343741',
            fontWeight: 'normal',
            textOverflow: 'ellipsis',
            overflow: 'hidden',
            lineHeight: '11px',
          }}
        >
          {`${currentVisit?.patient?.first_name || ''} ${currentVisit?.patient?.last_name || ''}`}
        </EuiText>
      </EuiText>
    ) : currentVisit?.visit_type || currentVisit?.patient ? (
      <EuiFlexItem>
        {currentVisit?.visit_type && (
          <EuiText
            style={{
              color: '#343741',
              fontWeight: 500,
              fontSize: '12px',
              textOverflow: 'ellipsis',
              overflow: 'hidden',
            }}
          >
            {currentVisit?.visit_type?.name}
          </EuiText>
        )}
        {currentVisit?.patient && (
          <ul>
            <li
              style={{
                fontSize: '11px',
                color: '#343741',
                fontWeight: 'normal',
                textOverflow: 'ellipsis',
                overflow: 'hidden',
              }}
            >
              {`${currentVisit?.patient?.first_name || ''} ${currentVisit?.patient?.last_name || ''}`}
            </li>
          </ul>
        )}
      </EuiFlexItem>
    ) : null;

    const timezone = currentVisit.patient?.address?.timezone;
    const time = `(${formatDate(currentVisit.cx_start, TIME_FORMAT_NO_AM, timezone)} - ${formatDate(
      currentVisit.cx_end,
      TIME_FORMAT_WITH_ZONE_NO_AM,
      timezone,
    )})`;
    const titleContent = `${formatDate(currentVisit.cx_start, TIME_FORMAT_NO_AM)} - ${formatDate(
      currentVisit.cx_end,
      TIME_FORMAT_NO_AM,
    )}`;
    return (
      <PatientVisitEvent
        titleContent={titleContent}
        secondaryTitle={timezone ? time : ''}
        showIcon={false}
        selected={visit && visit?.id === currentVisit.id}
        event={event}
        timezone={timezone}
        extraContent={extraContent}
        maxHeight={'63px'}
        minHeight={view === 'week' ? '63px' : '43px'}
      />
    );
  };

  const renderCustomResource = (resource) => {
    const { id, drive_time, drive_distance } = visits?.find(({ fp_id }) => fp_id === resource.id) || {};

    return (
      <div className="md-resource-header-template-cont">
        <EuiFlexItem style={{ flexDirection: 'row' }} className="md-resource-header-template-name">
          <EuiAvatar
            style={{ fontSize: '12px', marginRight: '0.3rem' }}
            color="#79aad9"
            size="s"
            name={resource.name ? resource.name : ""}
          />
          <EuiText style={{ fontSize: '13px' }}>{resource.name}</EuiText>
        </EuiFlexItem>
        {id && !drive_time && !drive_distance ? (
          <EuiBadge style={{ marginTop: '5px', display: 'flex' }} color="warning">
            Unknown starting address
          </EuiBadge>
        ) : null}
      </div>
    );
  };

  const onChangeView = (optionId) => {
    changeView(optionId);
  };

  const onDateChange = (date: moment.Moment) => {
    const startDate = formatDate(date, DB_DATE_FORMAT);
    setStartOfCalendar(date.startOf('day'));
    setEndOfCalendar(date.endOf('day'));

    fetchData(startDate);
  };

  const renderMyHeader = () => (
    <ScheduleCalendarHeader
      onDateChange={onDateChange}
      calendarView={view}
      startOfCalendar={startOfCalendar}
      onChangeView={onChangeView}
    />
  );

  const changeView = async (type) => {
    let calView;
    await setView(type);
    if (type === 'day') {
      calView = {
        timeline: { type: 'day', startTime: '04:00', endTime: '23:59' },
      };
    } else if (type === 'week') {
      calView = {
        timeline: {
          type: 'week',
          eventList: true,
        },
      };
    }
    setCalView(calView);
  };

  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  const onEditVisit = (visit: AlayacareVisit) => {
    const link = !isFieldAccount() ? edit_visit_partial_admin_patient_path : edit_visit_partial_field_patient_path;
    setEditFlyoutPath(
      link(visit.patient.id, {
        visit_id: visit.visit_id,
        alayacare_visit_id: visit.alayacare_visit_id,
        patient_id: visit.patient.id,
      }),
    );
  };

  let editFlyout;
  if (editFlyoutPath) {
    editFlyout = (
      <MedFlyout
        showFooter
        cancelButton={{ text: 'Cancel', onClick: () => setEditFlyoutPath(null) }}
        confirmButton={{
          text: 'Save',
          // eslint-disable-next-line @typescript-eslint/no-empty-function
          onClick: () => {},
          type: 'submit',
          form: 'editVisitForm',
          color: 'danger',
        }}
        title="Edit Visit"
        show={!!editFlyoutPath}
        onClose={() => setEditFlyoutPath(null)}
        size="s"
        dataTestId="edit"
      >
        <RemotePartial
          path={editFlyoutPath}
          partialProps={{
            redirectPath: admin_capacity_availability_path(),
          }}
        />
      </MedFlyout>
    );
  }

  const onVisitUpdated = async (visitData) => {
    setVisitUpdates((currentVisitUpdates) => ({
      ...currentVisitUpdates,
      [`${visitData.visit_id}`]: {
        notes: visitData.notes,
      },
    }));
    setToggleReloadCalendarData((current) => !current);
  };

  const onClearAll = () => {
    setStartOfCalendar(moment());
    changeView('day');
    if (view === 'day') {
      fetchData(moment());
    }
  };
  return (
    <>
      {editFlyout}
      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>Schedule</h2>
          </EuiTitle>
        </EuiPageContentHeader>
        <EuiSpacer size="m" />
        <VisitStatusKey padding="0" />
        <ScheduleFilters
          demandPartnerOptions={demandPartnerOptions}
          selectedDemandPartner={selectedDemandPartner}
          onChangeDemandPartner={onChangeDemandPartner}
          fieldProviderOptions={fieldProviderOptions}
          selectedFieldProvider={selectedFieldProvider}
          onChangeFieldProvider={onChangeFieldProvider}
          onlyShowWorkingToggle={onlyShowWorkingToggle}
          setOnlyShowWorkingToggle={setOnlyShowWorkingToggle}
          shiftCoverageToggle={shiftCoverageToggle}
          setShiftCoverageToggle={setShiftCoverageToggle}
          onClearAll={onClearAll}
        />
        <MedEventcalendar
          themeVariant="light"
          view={calView}
          renderScheduleEvent={renderScheduleEvent}
          renderHeader={renderMyHeader}
          renderResource={renderCustomResource}
          selectedDate={startOfCalendar}
          resources={resources}
          colors={shiftCoverageToggle && view !== 'week' ? availabilityColors : []}
          data={filterCalendarEvents}
          dataTimezone="utc"
          timezonePlugin={momentTimezone}
          onEventClick={(e) => {
            if (e.event?.eventType === ScheduleEventType.DRIVE) {
              return;
            }
            setVisit(e.event);

            if (timerRef.current) {
              clearTimeout(timerRef.current);
            }
            setVisitAnchor(e.domEvent.target);
            setOpen(true);
          }}
          onSelectedDateChange={async (e) => {
            const date = e.date;
            const startDate = formatDate(moment(date), DB_DATE_FORMAT);
            const newStartDate = moment(startDate).format();
            setStartOfCalendar(moment(newStartDate));
            updateFilter(
              FILTERS_SCHEDULE_FILTER_ID,
              SCHEDULE_CALENDAR_DATE_FILTER_KEY,
              moment(startDate).format('Y-M-D'),
            );
            fetchData(newStartDate);
          }}
        />
      </EuiPageContent>
      <CalendarPopup width={550} isOpen={isOpen} visitAnchor={visitAnchor}>
        <VisitPopup
          visit={visit}
          setOpen={(isOpen) => {
            setOpen(isOpen);
          }}
          current_user={current_user}
          onVisitUpdated={onVisitUpdated}
          onEditVisit={onEditVisit}
        />
      </CalendarPopup>
      <EuiGlobalToastList
        toasts={toasts}
        dismissToast={(removedToast) => {
          removeToast(removedToast.id);
        }}
        toastLifeTimeMs={10000}
      />
    </>
  );
};

export const CapacityPage = withAdminLayout(CapacityPageScreen);
