import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  EuiButton,
  EuiCallOut,
  EuiCard,
  EuiFlexGroup,
  EuiFlexItem,
  EuiHorizontalRule,
  EuiIconTip,
  EuiLoadingSpinner,
  EuiNotificationBadge,
  EuiPageContent,
  EuiPageContentBody,
  EuiSpacer,
  EuiText,
  EuiTitle,
} from '@elastic/eui';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { Patient, SuggestedVisit } from '@/common/types';
import { filter, find, map, uniqBy } from 'lodash';
import { MedComboBox, MedHiddenField, MedTextArea, MedTextField } from '@/common/components/forms';
import { useSyncForm } from '@/common/hooks/useSyncForm/useSyncForm';
import {
  admin_alayacare_create_path,
  alayacare_visit_admin_patient_path,
  fetch_suggested_visits_admin_patient_path,
  visit_types_admin_patient_path,
} from '@/common/routes';
import {
  formatDate,
  LONG_DATE_FORMAT,
  TIME_FORMAT,
  TIME_FORMAT_WITH_ZONE,
  DB_DATE_FORMAT,
} from '@/common/utils/dates/dates';
import moment from 'moment-timezone';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { MbscCalendarEventData, momentTimezone } from '@mobiscroll/react';
import { apptId, checkVisitDate, eventFormatter } from './SchedulerUtils';
import { Services } from './components/services';
import CustomEuiCheckableCard from './components/CustomCheckableCard';

// Move to types
type Program = {
  id: string;
  name: string;
  services: Service[];
};

type VisitType = {
  id: string;
  name: string;
  alayacare_id: string;
  services: Service[];
  duration?: number;
};

type Service = {
  id: string;
  name: string;
  alayacare_id: string;
  selected: boolean;
  type: 'program' | 'visit_type'; // program | visit_type
  duration: number;
};

interface AlayacareCreateVisitProps extends AdminPageProps {
  patient: Patient;
  programs: Program[];
  service_codes: any; // @TODO: fix this any type
  enable_form?: boolean;
}

momentTimezone.moment = moment;

const randomId = () => Math.floor(Math.random() * 8000) + 1;

const visitDisplayDate = (visit, timezone) =>
  `${formatDate(visit.cx_start, LONG_DATE_FORMAT, timezone)} ${formatDate(
    visit.cx_start,
    TIME_FORMAT,
    timezone,
  )} - ${formatDate(visit.cx_end, TIME_FORMAT_WITH_ZONE, timezone)}`;

const visitDriveTimes = (visit, timezone) =>
  `${formatDate(visit.start_time, TIME_FORMAT, timezone)} - ${formatDate(
    visit.end_time,
    TIME_FORMAT_WITH_ZONE,
    timezone,
  )}`;

// end range from start date when loading new visits.
const WEEKS_IN_ADVANCE = 3;

export const AlayacareCreateVisit: React.FC<AlayacareCreateVisitProps> = ({
  layout_props,
  patient,
  programs,
  service_codes,
  enable_form,
}) => {
  const [topSuggestions, setTopSuggestions] = useState([]);
  const [suggestedOptions, setSuggestedOptions] = useState([]);

  const [displayCalendar, setDisplayCalendar] = useState(false);
  const [loadingTopSuggestions, setLoadingTopSuggestions] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);

  // calendar dates
  const [endDateRange, setEndDateRange] = useState(moment().add(WEEKS_IN_ADVANCE, 'weeks'));
  const [startDateRange, setStartDateRange] = useState(moment());

  const [hasFetched, setHasFetched] = useState(false);
  const [error, setError] = useState('');
  const defaultErrorMessage = 'Something went wrong please try again';

  const { first_name, last_name, id: patientId } = patient;
  const patientFullName = `${first_name} ${last_name} `;

  // for service codes dropdown
  const serviceCodesKey = JSON.stringify(service_codes);
  const serviceCodesFormat = useMemo(() => {
    return filter(
      map(service_codes, (value, label) => ({ value, label })),
      (s) => isNaN(parseInt(s.label)), // filtering some labels being shown as numbers in production.
    );
  }, [serviceCodesKey]);

  // logging
  // for tracking when scheduling started. Timestamp when the cx clicked "Get Schedules" button.
  const [schedulingStartedAt, setSchedulingStartedAt] = useState(null);
  // total number of unique visits/timeslots selected during the scheduling process.
  const [totalNumberOfPicks, setTotalNumberOfPicks] = useState(new Set([]));

  const programsKey = programs.map((p) => p.id).join(',');
  const programOptions = useMemo(() => map(programs, (program) => ({ value: program.id, label: program.name })), [
    programsKey,
  ]);
  const [visitTypes, setVisitTypes] = useState<VisitType[]>([]);

  const visitTypesKey = visitTypes.map((vt) => vt.id).join(',');
  // for visit types dropdown
  const visitTypesOptions = useMemo(() => map(visitTypes, (v) => ({ value: v.alayacare_id, label: v.name })), [
    visitTypesKey,
  ]);

  const [services, setServices] = useState<Service[]>([]);
  const [serviceIds, setServiceIds] = useState<Set<string>>(new Set([]));
  const serviceIdKey = JSON.stringify(Array.from(serviceIds));

  const defaultProgramId = programs?.length > 0 && programs?.length === 1 ? [programs[0].id] : [];

  let initialFormValues: any = {
    visit_id: '',
    service_code_id: null,
  };

  if (enable_form) {
    initialFormValues = {
      program_id: defaultProgramId,
      visit_type_id: null,
      duration: null,
    };
  }

  const { form: getSchedulesForm, syncFormProps: getSchedulesFormProps } = useSyncForm({
    formId: 'getSchedulesForm',
    url: alayacare_visit_admin_patient_path(patient.id),
    method: 'get',
    formOptions: {
      defaultValues: initialFormValues,
    },
  });

  const { loading: createVisitLoading, form: createVisitForm, syncFormProps: createVisitFormProps } = useSyncForm({
    formId: 'createVisit',
    url: admin_alayacare_create_path(),
    method: 'post',
    formOptions: {
      defaultValues: {
        field_provider_id: null,
        ranking: null,
        total_number_of_picks: null,
        scheduling_started_at: null,
        run_id: null,
        drive_time: null,
        field_provider_name: null,
        total_score: null,
        drive_score: null,
        proximity_score: null,
        utilization_score: null,
        visit: {
          patient_id: patientId,
          program_id: null,
          visit_type_id: null,
          duration: null,
          service_ids: [],
          start_time: null,
          end_time: null,
          service_instructions: '',
        },
      },
    },
  });

  const { watch, setValue } = getSchedulesForm;
  const currentVisitTypeId = watch(enable_form ? 'visit_type_id' : 'service_code_id');
  const currentProgramId = watch('program_id');
  const visitId = watch('visit_id');
  const currentDuration = watch('duration');
  const { setValue: setCreateVisitValue } = createVisitForm;

  const disableCreate = currentVisitTypeId && visitId;

  const formatVisits = (visits) => {
    const options = visits.filter((v) => !checkVisitDate(v.start_time));

    options.forEach((visit, i) => {
      visit.id = randomId();
      visit.rank = i + 1;
    });
    return options;
  };

  useEffect(() => {
    if (selectedVisit && selectedVisit?.fp_id) {
      if (enable_form) {
        // set visit fields
        setCreateVisitValue('visit.start_time', selectedVisit.start_time);
        setCreateVisitValue('visit.end_time', selectedVisit.end_time);
        setCreateVisitValue('visit.program_id', currentProgramId);
        setCreateVisitValue('visit.visit_type_id', currentVisitTypeId[0]);
        setCreateVisitValue('visit.service_ids', Array.from(serviceIds).join(','));
        setCreateVisitValue('visit.duration', currentDuration);
      } else {
        setCreateVisitValue('start_time', selectedVisit.start_time);
        setCreateVisitValue('end_time', selectedVisit.end_time);
      }

      // set logging data
      setCreateVisitValue('field_provider_id', selectedVisit.fp_id);
      setCreateVisitValue('ranking', selectedVisit.rank);
      setCreateVisitValue('total_number_of_picks', totalNumberOfPicks.size);
      setCreateVisitValue('scheduling_started_at', schedulingStartedAt.utc().format());
      setCreateVisitValue('run_id', selectedVisit.run_id);
      setCreateVisitValue('drive_time', selectedVisit.expected_drive);
      setCreateVisitValue('field_provider_name', selectedVisit.fp_name);
      setCreateVisitValue('total_score', selectedVisit.total_score);
      setCreateVisitValue('drive_score', selectedVisit.drive_score);
      setCreateVisitValue('proximity_score', selectedVisit.proximity_score);
      setCreateVisitValue('utilization_score', selectedVisit.utilization_score);
    }
  }, [visitId]);

  useEffect(() => {
    if (currentVisitTypeId) {
      createVisitForm.setValue('service_code_id', currentVisitTypeId[0]);

      const selectedVisitType = visitTypes.find((v) => v.alayacare_id === currentVisitTypeId[0]);
      if (selectedVisitType) {
        createVisitForm.setValue('visit.visit_type_id', selectedVisitType.id);
      }
    }
  }, [currentVisitTypeId, visitId]);

  // everytime program is set/changed load visit types and set program services
  useEffect(() => {
    if (currentProgramId?.length) {
      loadVisitTypes();

      if (programs && programs.length) {
        const program = find(programs, (p) => p.id === currentProgramId[0]);

        if (program) {
          const initialServices = program.services;
          // set type so we can differenciate between program.services and visit_type.services
          initialServices.forEach((s) => (s.type = 'program'));

          setServices(initialServices);
        }
      }
    }
  }, [currentProgramId]);

  // when changing a visit type add visit_type.services to the list.
  useEffect(() => {
    if (currentVisitTypeId?.length) {
      const currentVisitType = visitTypes.find((vt) => vt.alayacare_id === currentVisitTypeId[0]);

      if (currentVisitType) {
        let newServices = [...currentVisitType.services];

        setServiceIds(new Set([...newServices.map((s) => s.id)]));

        // append program.services
        const programServices = services.filter((s) => s.type === 'program');
        newServices = uniqBy([...programServices, ...newServices], 'id');

        setServices(newServices);
      }
    }
  }, [currentVisitTypeId]);

  const currentVisitType = currentVisitTypeId?.length
    ? visitTypes?.find((vt) => vt.alayacare_id === currentVisitTypeId[0])
    : null;

  const visitTypeDuration = currentVisitType?.duration || 0;

  const selectedServices = services.filter((s) => serviceIds.has(s.id));
  const calculatedDuration = selectedServices.reduce((acc, s) => acc + s.duration, visitTypeDuration);

  useEffect(() => {
    setValue('duration', calculatedDuration);
  }, [calculatedDuration]);

  const timezone = patient?.address?.timezone;
  const [selectedVisit, setSelectedVisit] = useState(null);

  const fetchVisits = async ({
    start_date = null,
    end_date = null,
    top_suggestions = '0',
    service_code_id,
    duration,
  }) => {
    const response = await fetch(
      fetch_suggested_visits_admin_patient_path(patient.id, {
        program_id: currentProgramId[0],
        service_code_id: service_code_id,
        start_date,
        end_date,
        top_suggestions,
        duration,
      }),
    );
    // reset error message
    setError('');

    // determines if api was called at least once
    setHasFetched(true);

    if (response.status === 200) {
      const jsonResponse = await response.json();
      if (!jsonResponse?.success) {
        setError(jsonResponse?.error_message || defaultErrorMessage);
      }
      return jsonResponse;
    } else {
      console.error(response.body);
      setError(defaultErrorMessage);
      return {};
    }
  };

  const getSchedules = async () => {
    setSchedulingStartedAt(moment());
    setDisplayCalendar(false);
    setLoadingTopSuggestions(true);
    const json = await fetchVisits({
      top_suggestions: '1',
      service_code_id: currentVisitTypeId,
      duration: currentDuration,
    });
    setLoadingTopSuggestions(false);

    const visits = json.suggested_visits;
    if (visits?.length) {
      const options = formatVisits(visits);
      setTopSuggestions(options);
    }
  };

  const loadMore = async (start_date = null, end_date = null) => {
    setIsLoadingMore(true);
    const json = await fetchVisits({
      service_code_id: currentVisitTypeId,
      start_date,
      end_date,
      duration: currentDuration,
    });
    setIsLoadingMore(false);

    // always display the calendar after clicking load more.
    setDisplayCalendar(true);

    if (typeof json.suggested_visits !== 'undefined') {
      const visits = json.suggested_visits;
      const options = formatVisits(visits);
      setSuggestedOptions(options);
    }
  };

  const loadVisitTypes = async () => {
    // reset visit types
    setVisitTypes([]);
    setValue('visit_type_id', null);

    const result = await fetchVisitTypes();

    setVisitTypes(result);

    // if there's only 1 visit type then select
    if (result?.length && result.length === 1) {
      setValue('visit_type_id', [result[0].alayacare_id]);
    }
  };

  const fetchVisitTypes = async () => {
    const response = await fetch(visit_types_admin_patient_path(patient.id, { program_id: currentProgramId }));

    if (response.status === 200) {
      const jsonResponse = await response.json();
      const visitTypes = jsonResponse?.visit_types || [];
      return visitTypes;
    }
    return [];
  };

  const onSelectService = useCallback(
    (service) => {
      if (serviceIds.has(service.id)) {
        serviceIds.delete(service.id);
      } else {
        serviceIds.add(service.id);
      }
      setServiceIds(new Set(serviceIds));
    },
    [serviceIdKey],
  );

  const appointmentsCacheKey = suggestedOptions?.map(apptId).join();
  const calendarEvents: MbscCalendarEventData[] = useMemo(() => suggestedOptions.map(eventFormatter), [
    appointmentsCacheKey,
  ]);

  const onEventClick = ({ event: visit }) => {
    // don't select if no field provider set on the event
    if (!visit?.resource) {
      return;
    }
    const selectedVisitId = selectedVisit ? apptId(selectedVisit) : null;
    const calendarVisitId = apptId(visit);
    // unselect
    if (selectedVisitId === calendarVisitId) {
      setSelectedVisit(null);
      setValue('visit_id', null);
      return;
    }
    const newVisit: SuggestedVisit = find(suggestedOptions, (v) => apptId(v) === calendarVisitId);
    setSelectedVisit(newVisit);
    setValue('visit_id', visit.id);
    setTotalNumberOfPicks(totalNumberOfPicks.add(visit.id));
  };

  const onPageChange = async ({ firstDay, lastDay }) => {
    const start_date = formatDate(firstDay, DB_DATE_FORMAT);

    setSelectedVisit(null);
    setValue('visit_id', null);

    if (
      !moment(firstDay).isBetween(startDateRange, endDateRange) &&
      !moment(lastDay).isBetween(startDateRange, endDateRange)
    ) {
      // fetch for next 3 weeks including last day of the week
      const newEndDate = moment(firstDay).add(WEEKS_IN_ADVANCE, 'weeks').weekday(7);
      const endDateFormatted = formatDate(newEndDate, DB_DATE_FORMAT);

      await loadMore(start_date, endDateFormatted);
      setStartDateRange(moment(firstDay));
      setEndDateRange(newEndDate);
    }
  };

  return (
    <div>
      <AdminLayout {...layout_props}>
        <EuiPageContent>
          <EuiFlexGroup alignItems="center" gutterSize="xl" style={{ marginBottom: 20 }} wrap responsive={false}>
            <EuiFlexItem grow={false}>
              <EuiTitle size="l">
                <h1>Suggested Visits for {patientFullName}</h1>
              </EuiTitle>
            </EuiFlexItem>
          </EuiFlexGroup>
          <EuiSpacer size="xl" />
          <EuiPageContentBody>
            <SyncForm {...getSchedulesFormProps}>
              <MedHiddenField name="visit_id" readOnly hidden />
              <EuiSpacer size="s" />
              {!enable_form && (
                <>
                  <EuiText style={{ fontWeight: 'bold' }}>
                    <p>Select a service from the list</p>
                  </EuiText>
                  <MedComboBox
                    width="100%"
                    name="service_code_id"
                    options={serviceCodesFormat}
                    placeholder="Please select a service from the list"
                    singleSelection={{ asPlainText: true }}
                  />
                </>
              )}
              {enable_form && (
                <>
                  <EuiText style={{ fontWeight: 'bold' }}>
                    <p>Program</p>
                  </EuiText>
                  <MedComboBox
                    width="100%"
                    name="program_id"
                    disabled={programs?.length === 1}
                    options={programOptions}
                    placeholder="Please select a program from the list"
                    singleSelection={{ asPlainText: true }}
                    isClearable={false}
                  />
                  <EuiSpacer size="l" />
                  <EuiText style={{ fontWeight: 'bold' }}>
                    <p>Visit Type</p>
                  </EuiText>
                  <MedComboBox
                    width="100%"
                    name="visit_type_id"
                    disabled={visitTypes?.length === 1}
                    options={visitTypesOptions}
                    placeholder="Please select a visit type the list"
                    singleSelection={{ asPlainText: true }}
                    isClearable={false}
                  />

                  {currentVisitTypeId && (
                    <Services services={services} selectedIds={serviceIds} onSelectService={onSelectService} />
                  )}
                  <EuiSpacer size="l" />
                  {currentVisitTypeId && (
                    <MedTextField style={{ width: '100px' }} label="Visit Duration" name="duration" />
                  )}
                </>
              )}
            </SyncForm>

            <EuiSpacer size="xl" />
            <EuiButton
              onClick={getSchedules}
              disabled={!currentVisitTypeId}
              type="button"
              form="getSchedulesForm"
              fill
              isLoading={loadingTopSuggestions}
            >
              Get schedules
            </EuiButton>
            <EuiSpacer size="xl" />

            {error && <EuiCallOut size="s" color="danger" title={error} />}
            {!error && hasFetched && topSuggestions?.length === 0 && suggestedOptions?.length === 0 && (
              <EuiText>
                <p>No availability found.</p>
              </EuiText>
            )}

            {topSuggestions?.length !== 0 && !displayCalendar && (
              <>
                <EuiText>
                  <p>Suggested Visits Times:</p>
                </EuiText>

                {topSuggestions.map((visit) => {
                  return (
                    <CustomEuiCheckableCard
                      key={visit.id}
                      id={`${visit.id}-visit`}
                      label={
                        <EuiText style={{ marginTop: '-4px' }}>
                          <EuiNotificationBadge size="m" style={{ backgroundColor: '#ef0075', marginRight: '0.5rem' }}>
                            {visit.rank}
                          </EuiNotificationBadge>
                          {visitDisplayDate(visit, timezone)}
                          {!visit.fp_id && (
                            <>
                              <EuiNotificationBadge
                                size="m"
                                style={{
                                  backgroundColor: '#f8e9e9',
                                  marginRight: '0.5rem',
                                  float: 'right',
                                  color: 'black',
                                }}
                              >
                                <EuiIconTip
                                  aria-label="Warning"
                                  size="s"
                                  type="alert"
                                  color="warning"
                                  content="This visit has missing configuration, please select another one."
                                />
                                Missing Setup
                              </EuiNotificationBadge>
                            </>
                          )}
                        </EuiText>
                      }
                      checkableType="checkbox"
                      value="checkbox1"
                      disabled={!visit?.fp_id}
                      checked={selectedVisit?.id === visit.id}
                      onChange={() => {
                        if (selectedVisit?.id === visit.id) {
                          setSelectedVisit(null);
                          setValue('visit_id', null);
                          return;
                        }
                        // avoid selecting visits without field provider set.
                        if (!visit.fp_name || !visit.fp_id) {
                          return;
                        }
                        setSelectedVisit(visit);
                        setValue('visit_id', visit.id);
                        setTotalNumberOfPicks(totalNumberOfPicks.add(visit.id));
                      }}
                    />
                  );
                })}

                {!selectedVisit && (
                  <>
                    <EuiSpacer size="xl" />
                    <EuiFlexItem style={{ alignItems: 'center' }}>
                      <EuiButton
                        style={{ color: 'white' }}
                        fill
                        onClick={() => loadMore()}
                        isLoading={isLoadingMore}
                        iconSide="right"
                      >
                        Load More
                      </EuiButton>
                    </EuiFlexItem>
                  </>
                )}
              </>
            )}

            {displayCalendar && (
              <>
                <EuiSpacer size="l" />
                <EuiHorizontalRule />
                {isLoadingMore && (
                  <EuiFlexGroup alignItems="center">
                    <EuiLoadingSpinner style={{ marginLeft: '1rem' }} size="l" />
                    <EuiText style={{ fontSize: '12px', marginLeft: '1rem', display: 'inline-block' }}>
                      Loading more visits, please wait ...
                    </EuiText>
                  </EuiFlexGroup>
                )}
                <EuiSpacer size="l" />
                <MedEventcalendar
                  view={{ schedule: { type: 'week', startDay: 1, endDay: 7, startTime: '08:00', endTime: '20:00' } }}
                  data={calendarEvents}
                  dataTimezone="utc"
                  displayTimezone={timezone}
                  timezonePlugin={momentTimezone}
                  onEventClick={onEventClick}
                  onPageChange={onPageChange}
                  themeVariant="light"
                />
                <EuiSpacer size="l" />
              </>
            )}

            {selectedVisit?.start_time && (
              <>
                <EuiSpacer size="xl" />
                <EuiText style={{ fontWeight: 'bold' }}>
                  <p>Visit Details</p>
                </EuiText>
                <EuiCard
                  textAlign="left"
                  title={
                    <EuiText>
                      <EuiNotificationBadge size="m" style={{ backgroundColor: '#ef0075', marginRight: '0.5rem' }}>
                        {selectedVisit.rank}
                      </EuiNotificationBadge>
                      {visitDisplayDate(selectedVisit, timezone)}
                    </EuiText>
                  }
                  description={
                    <span>
                      Field Provider: {selectedVisit.fp_name} <br />
                      Route Optimized Time: {visitDriveTimes(selectedVisit, timezone)} <br />
                      Expected Drive: {selectedVisit?.expected_drive}m <br />
                      Score: {selectedVisit?.total_score} <br />
                      Score components: drive score {selectedVisit?.drive_score}, proximity score:{' '}
                      {selectedVisit?.proximity_score}, utilization score: {selectedVisit?.utilization_score}
                    </span>
                  }
                ></EuiCard>
              </>
            )}

            <EuiSpacer size="s" />
            {disableCreate && (
              <>
                <SyncForm {...createVisitFormProps}>
                  <MedHiddenField name="service_code_id" readOnly hidden />
                  <MedHiddenField name="field_provider_id" readOnly hidden />
                  <MedHiddenField name="ranking" readOnly hidden />
                  <MedHiddenField name="total_number_of_picks" readOnly hidden />
                  <MedHiddenField name="scheduling_started_at" readOnly hidden />
                  <MedHiddenField name="field_provider_name" readOnly hidden />
                  <MedHiddenField name="drive_time" readOnly hidden />
                  <MedHiddenField name="run_id" readOnly hidden />
                  <MedHiddenField name="start_time" readOnly hidden />
                  <MedHiddenField name="end_time" readOnly hidden />
                  <MedHiddenField name="total_score" readOnly hidden />
                  <MedHiddenField name="drive_score" readOnly hidden />
                  <MedHiddenField name="proximity_score" readOnly hidden />
                  <MedHiddenField name="utilization_score" readOnly hidden />

                  <MedHiddenField name="visit.start_time" readOnly hidden />
                  <MedHiddenField name="visit.end_time" readOnly hidden />
                  <MedHiddenField name="visit.patient_id" readOnly hidden />
                  <MedHiddenField name="visit.service_ids" readOnly hidden />
                  <MedHiddenField name="visit.duration" readOnly hidden />
                  <MedHiddenField name="visit.program_id" readOnly hidden />
                  <MedHiddenField name="visit.visit_type_id" readOnly hidden />
                  <MedTextArea
                    name="visit.service_instructions"
                    label="Service Instructions"
                    fullWidth
                    placeholder="Parking instructions, door code, anything patient wants field provider to know prior to the visit."
                  />
                  <EuiSpacer size="s" />
                </SyncForm>
                <EuiSpacer size="s" />
                <EuiButton
                  disabled={!disableCreate}
                  type="submit"
                  form="createVisit"
                  fill
                  isLoading={createVisitLoading}
                >
                  Create Visit
                </EuiButton>
              </>
            )}
          </EuiPageContentBody>
        </EuiPageContent>
      </AdminLayout>
    </div>
  );
};
