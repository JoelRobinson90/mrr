import { VisitPopup } from '@/common/components/Calendar/VisitPopup/VisitPopup';
import { PatientVisitEvent } from '@/common/components/Calendar/PatientVisitEvent/PatientVisitEvent';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { MedFlyout } from '@/common/components/MedFlyout/MedFlyout';
import { RemotePartial } from '@/common/components/RemotePartial/RemotePartial';
import {
  admin_patient_path,
  field_patient_path,
  edit_visit_partial_field_patient_path,
  edit_visit_partial_admin_patient_path,
  admin_capacity_get_availability_by_date_path,
  field_capacity_get_availability_by_date_path,
} from '@/common/routes';
import { Patient, AlayacareVisit } from '@/common/types';
import { formatDate, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { EuiFlexItem, EuiGlobalToastList, EuiText } from '@elastic/eui';
import { MbscCalendarEventData, momentTimezone } from '@mobiscroll/react';
import moment from 'moment';
import React, { FC, useCallback, useMemo, useState, useEffect } from 'react';
import { CalendarPopup } from '../capacity/components/CalendarPopup';
import { formatVisitDataForCalendar, removeSystemCancellationsFromVisits } from '@/common/utils/calendar/utils';
import { debounce, find } from 'lodash';
import { VisitStatusKey } from '@/common/components/VisitStatusKey/VisitStatusKey';
import { useFlashToast } from '@/common/components/FlashToast/FlashToast';
import displayStatus from '@/common/utils/statuses/displayStatus';

momentTimezone.moment = moment;

interface PatientVisitsCalendarTabProps {
  patient: Patient;
  visits?: AlayacareVisit[];
  enable_push_to_external?: boolean;
  current_user: any;
  added_visit_id?: string;
}

export const PatientVisitsCalendarTab: FC<PatientVisitsCalendarTabProps> = ({
  patient,
  current_user,
  added_visit_id,
}) => {
  const [editFlyoutPath, setEditFlyoutPath] = useState<string | null>(null);
  const timezone = patient?.address?.timezone;
  const [visits, setVisits] = useState([]);
  const [toasts, setToasts] = useState([]);
  const [toggleReloadCalendarData, setToggleReloadCalendarData] = useState<boolean>(false);
  const [visitUpdates, setVisitUpdates] = useState({});
  const { addNotice } = useFlashToast();

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

  const isFieldAccount = () => {
    const fieldAccountTypes = ['FieldProvider', 'ExternalAccount'];
    return fieldAccountTypes.includes(current_user?.account_type);
  };

  useEffect(() => {
    fetchInitialData();
  }, []);

  useEffect(() => {
    if (visits?.length && added_visit_id) {
      addNotice('Visit scheduled!');
      const lastCreatedVisit = find(visits, (v) => v.id.toString() === added_visit_id || v.visit_id === added_visit_id);
      // in case the visit it's not in the current month, take the user to the scheduled visit
      if (lastCreatedVisit) {
        setCalendarSelectedDate(moment(lastCreatedVisit.start_date));
      }
    }
  }, [visits?.length]);

  const fetchInitialData = async () => {
    const startDate = moment().subtract(36, 'M').startOf('month').format();
    const endDate = moment().add(24, 'M').endOf('month').format();

    await fetchData(startDate, endDate);
  };

  const fetchData = useCallback(
    debounce(async (startDate = moment(), endDate = null) => {
      addToast('Loading, please wait ...', '');
      const newStartDate = moment(startDate).startOf('month').format();
      let newEndDate;
      if (endDate) {
        newEndDate = moment(endDate).endOf('month').format();
      } else {
        newEndDate = moment(newStartDate).add(1, 'M').endOf('month').format();
      }

      let response;
      if (isFieldAccount()) {
        response = await fetch(
          field_capacity_get_availability_by_date_path({
            patient_id: patient.id,
            start_date: newStartDate,
            end_date: newEndDate,
          }),
        );
      } else {
        response = await fetch(
          admin_capacity_get_availability_by_date_path({
            patient_id: patient.id,
            start_date: newStartDate,
            end_date: newEndDate,
          }),
        );
      }
      if (response?.status === 200) {
        const jsonResponse = await response.json();

        const { visits: newVisits, error_message: errorMsg } = jsonResponse;
        if (newVisits) {
          setVisits(removeSystemCancellationsFromVisits(newVisits));
          if (newVisits.length > 0) {
            setHasACVisits(true);
          }
        }
        setToasts([]);
        if (errorMsg) {
          addToast('Error:', errorMsg);
        }
      } else {
        addToast('There was an error when loading data.', 'Please try again.');
      }
    }, 200),
    [],
  );
  const onEditVisit = (visit: AlayacareVisit) => {
    !isFieldAccount()
      ? setEditFlyoutPath(
          edit_visit_partial_admin_patient_path(patient.id, {
            visit_id: visit.visit_id,
            alayacare_visit_id: visit.alayacare_visit_id,
            patient_id: patient.id,
          }),
        )
      : setEditFlyoutPath(
          edit_visit_partial_field_patient_path(patient.id, {
            visit_id: visit.visit_id,
            alayacare_visit_id: visit.alayacare_visit_id,
            patient_id: patient.id,
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
          color: 'primary',
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
            redirectPath: !isFieldAccount() ? admin_patient_path(patient.id) : field_patient_path(patient.id),
          }}
        />
      </MedFlyout>
    );
  }
  const calendarEvents: MbscCalendarEventData[] = useMemo(() => {
    return visits?.length > 0 && formatVisitDataForCalendar(visits, { visitUpdates });
  }, [visits?.length, toggleReloadCalendarData]);

  const timerRef = React.useRef(null);

  const [visit, setVisit] = useState(null);
  const [visitAnchor, setVisitAnchor] = useState(null);
  const [isOpen, setOpen] = useState(false);
  const [calendarSelectedDate, setCalendarSelectedDate] = useState(moment());

  const renderLabel = useCallback(
    (event) => {
      const visitFields = event?.original;
      const extraContent =
        visitFields?.fullDay &&
        (visitFields.cancelled ? (
          <EuiText style={{ color: '#3d3d3d' }}>
            {typeof visitFields.cancel_code === 'string' ? visitFields.cancel_code : visitFields?.cancel_code?.code}
            <EuiText
              style={{
                fontSize: '13px',
                color: '#343741',
                fontWeight: 'normal',
                textOverflow: 'ellipsis',
                overflow: 'hidden',
                lineHeight: '11px',
              }}
            >
              {`${visitFields?.patient?.first_name || ''} ${visitFields?.patient?.last_name || ''}`}
            </EuiText>
          </EuiText>
        ) : (
          <EuiFlexItem>
            <EuiText style={{ color: '#343741', fontWeight: 500, fontSize: '15px' }}>
              {visitFields.visit_type?.name || ''} {visitFields.fp_name ? '-' : ''} {visitFields.fp_name || ''}
            </EuiText>
            <ul style={{ fontSize: '14px', lineHeight: '14px' }}>
              {[...(visitFields?.services || [])].slice(0, 2).map((s) => (
                <li key={s.id} style={{ fontWeight: 'normal', textOverflow: 'ellipsis', overflow: 'hidden' }}>
                  {s.name}
                </li>
              ))}
            </ul>
          </EuiFlexItem>
        ));
      const time = formatDate(visitFields.cx_start, TIME_FORMAT_WITH_ZONE, timezone);

      const shouldHighlight =
        visitFields.id === parseInt(added_visit_id, 10) || visitFields.visit_id === added_visit_id;

      return (
        <PatientVisitEvent
          event={event}
          titleContent={displayStatus(visitFields?.status)}
          secondaryTitle={time}
          selected={visit && visit?.id === visitFields.id}
          extraContent={extraContent}
          timezone={timezone}
          highlighted={shouldHighlight}
        />
      );
    },
    [visit?.id],
  );
  const [hasACVisits, setHasACVisits] = useState(true);

  const onVisitUpdated = async (visitData) => {
    setVisitUpdates((currentVisitUpdates) => ({
      ...currentVisitUpdates,
      [`${visitData.visit_id}`]: {
        notes: visitData.notes,
      },
    }));
    setToggleReloadCalendarData((current) => !current);
  };

  return (
    <>
      <VisitStatusKey />
      <CalendarPopup width={545} isOpen={isOpen} visitAnchor={visitAnchor}>
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
      {!hasACVisits && <EuiText style={{ fontSize: '14px' }}>No visits found in Alayacare for this patient.</EuiText>}

      <>
        <MedEventcalendar
          view={{
            calendar: { type: 'month', size: 1, labels: 2 },
          }}
          height={870}
          eventMarginBottom="2.4em"
          renderLabel={renderLabel}
          data={calendarEvents}
          selectedDate={calendarSelectedDate}
          dataTimezone="utc"
          displayTimezone={timezone}
          timezonePlugin={momentTimezone}
          onEventClick={(e) => {
            setVisit(e.event);

            if (timerRef.current) {
              clearTimeout(timerRef.current);
            }
            setVisitAnchor(e.domEvent.target);
            setOpen(true);
          }}
          themeVariant="light"
        />
      </>
      {editFlyout}
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
