import React, { useState, useMemo, useEffect, useRef } from 'react';
import {
  EuiBreadcrumbs,
  EuiCallOut,
  EuiFlexGroup,
  EuiFlexItem,
  EuiLoadingSpinner,
  EuiPageContent,
  EuiPageContentBody,
  EuiSpacer,
  EuiText,
  EuiTitle,
} from '@elastic/eui';
import queryString from 'query-string';

import { withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { withFieldLayout } from '@/field/components/FieldLayout/FieldLayout';
import { Patient, SuggestedVisit } from '@/common/types';
import { find, every } from 'lodash';
import { admin_patients_path, admin_patient_path, field_patients_path, field_patient_path } from '@/common/routes';
import moment from 'moment-timezone';
import { MedEventcalendar } from '@/common/components/MedEventcalendar/MedEventcalendar';
import { MbscCalendarEventData, momentTimezone } from '@mobiscroll/react';
import { apptId, eventFormatter, VISIT_RANK_CATEGORIES } from './SchedulerUtils';
import { Program } from '@/common/types/index';
import { VisitSidePanel } from './VisitSidePanel';
import { CreateVisitModal } from './CreateVisitModal';
import { MedToggleButton } from './components/MedToggleButton/MedToggleButton';
import { VisitSlot } from './components/VisitSlot/VisitSlot';
import { CalendarCustomHeader } from './components/CalendarCustomHeader/CalendarCustomHeader';
import {
  useCreateAlayacareVisitMutation,
  useGetPreferredProvidersQuery,
  useGetSchedulerDataQuery,
  useRescheduleVisitMutation,
  useUpdateAlayacareVisitMutation,
} from '@/generated/graphql';
import { useFlashToast } from '@/common/components/FlashToast/FlashToast';
import { DB_DATE_FORMAT, formatDate, formatUtc } from '@/common/utils/dates/dates';
import './ScheduleVisitPage.scss';
import { gql, useLazyQuery } from '@apollo/client';
import FilterPreferredProviders from '@/admin/components/FilterPreferredProviders/FilterPreferredProviders';
import { OptionsProps } from '@/common/components/SelectableFilter/SelectableFilter';

interface ScheduleVisitPageProps {
  patient_id: string;
  current_user?: any;
  modalRedirectPath?: string;
}

momentTimezone.moment = moment;

const ON_SUCCESS_VISIT_QUERY = gql`
  query OnSuccessVisitQuery($id: ID!) {
    getVisit(id: $id) {
      maId
      externalId
      displayStatus
      startTime
      endTime
      cxStart
      cxEnd
      arrivalWindowStart
      arrivalWindowEnd
      patient {
        maId
      }
      program {
        maId
      }
      visitType {
        maId
      }
    }
  }
`;

// Number of weeks to show
const WEEKS_IN_ADVANCE = 8;

// TODO: [EL] accept program_id and other params from props in addition to params

export const ScheduleVisitPageComponent: React.FC<ScheduleVisitPageProps> = ({
  patient_id,
  current_user,
  modalRedirectPath,
}) => {
  const currentParams = useMemo(() => queryString.parse(location.search), []);
  const {
    duration,
    program_id,
    visit_type_id,
    service_ids,
    existing_visit_alayacare_id,
    external_id,
    iframe,
    limit_arrival_window,
    ignore_existing_visit_conflicts,
  } = currentParams;

  const currentDuration = duration?.toString();
  const currentProgramId = program_id?.toString();
  const currentVisitTypeId = visit_type_id?.toString();
  const existingVisitAlayacareId = existing_visit_alayacare_id?.toString();
  const externalId = external_id?.toString();
  const limitArrivalWindow = limit_arrival_window?.toString();
  const ignoreExistingVisitConflicts = ignore_existing_visit_conflicts?.toString() === 'true';
  const currentServiceIds = service_ids?.toString().split(',') || [];
  const availableDateRange = useMemo(() => [moment(), moment().add(WEEKS_IN_ADVANCE, 'weeks')], []);
  const [startDate, endDate] = availableDateRange;

  const { data: schedulerData, loading: loadingSchedulerData, error: schedulerDataError } = useGetSchedulerDataQuery({
    variables: {
      patient_id,
      program_id: currentProgramId,
      service_code_id: currentVisitTypeId,
      top_suggestions: '',
      start_date: formatDate(startDate, DB_DATE_FORMAT),
      end_date: formatDate(endDate, DB_DATE_FORMAT),
      duration: duration?.toString(),
      existing_visit_alayacare_id: existingVisitAlayacareId?.toString(),
      external_id: externalId?.toString(),
      limit_arrival_times: limitArrivalWindow?.toString(),
      ignore_existing_visit_conflicts: ignoreExistingVisitConflicts,
      visit_type_id: currentVisitTypeId,
    },
  });

  const patient = schedulerData?.getPatient;
  const programs = patient?.programs;
  const suggestedOptions = schedulerData?.getSchedulerData?.suggestedVisits || [];
  const serviceRequests = schedulerData?.getPatient.serviceRequests;

  const currentProgram = useMemo(() => {
    return find(programs, (p) => p.id === currentProgramId);
  }, [currentProgramId, programs?.length]);

  const currentVisitType = useMemo(() => {
    return currentProgram?.visit_types?.find((vt) => vt.id === currentVisitTypeId);
  }, [currentVisitTypeId, currentProgram?.name]);

  // NOTE: due to a bug with EuiCheckboxGroup we added a prefix to id's so this is for removing the prefix before sending.
  const formattedServiceIds = [...currentServiceIds]?.map((s) => s?.replace('service_', ''));

  const currentServices = useMemo(() => {
    if (currentProgram?.id && currentVisitType?.id) {
      const programServices = currentProgram.services;
      return programServices.filter((s) => formattedServiceIds.includes(s.id));
    }
    return [];
  }, [currentProgram?.name, currentVisitType?.name]);

  const [preferredProviderFilterWarning, setPreferredProviderFilterWarning] = useState(false);
  const { loading: isLoadingPreferred, data: preferredProvidersData } = useGetPreferredProvidersQuery({
    variables: {
      patient_id,
    },
  });

  const optionsPreferredProviders: OptionsProps[] = useMemo<OptionsProps[]>(() => {
    if (!preferredProvidersData || !currentVisitType) {
      return [];
    }

    const { requirements } = currentVisitType;
    const requirementRoles =
      requirements.length === 0 ? ['field_provider'] : requirements.map((req) => req.providerRole);

    // Show only preferred providers with a role relevant to the visit type
    const providers = preferredProvidersData.getPreferredProviders.filter(({ role }) =>
      requirementRoles.includes(role),
    );

    return providers.map(({ displayName, fpId, role }) => {
      const usePreferred = requirements.find((req) => req.providerRole === role)?.usePreferredProvider;
      return {
        label: displayName,
        checked: usePreferred ? 'on' : undefined,
        value: fpId,
      };
    });
  }, [JSON.stringify(preferredProvidersData?.getPreferredProviders), currentVisitType?.id]);

  const [gqlCreateFunc, { loading: gqlCreateLoading, data: gqlCreateData }] = useCreateAlayacareVisitMutation();
  const [gqlUpdateFunc, { loading: gqlUpdateLoading, data: gqlUpdateData }] = useUpdateAlayacareVisitMutation();
  const [
    gqlRescheduleVisit,
    { loading: gqlRescheduleLoading, data: gqlRescheduleVisitData },
  ] = useRescheduleVisitMutation();
  const gqlCreateSuccess = !!gqlCreateData?.createAlayacareVisit?.visitId;
  const gqlUpdateSuccess = !!gqlUpdateData?.alayacareUpdateVisit?.visit?.id;
  const gqlRescheduleSuccess = !!gqlRescheduleVisitData?.rescheduleVisit?.visitId;

  const [gqlOnSuccessFunc] = useLazyQuery(ON_SUCCESS_VISIT_QUERY);

  const readyToSchedule = currentDuration && currentProgramId && currentVisitTypeId;
  const keepEditModalOpen = !readyToSchedule;

  const [isEditModalOpen, setIsEditModalOpen] = useState(keepEditModalOpen);
  const [scheduledVisit, setScheduledVisit] = useState<SuggestedVisit | null>(null);
  const [selectedVisit, setSelectedVisit] = useState<SuggestedVisit | null>(null);
  const [selectedPreferredProviders, setSelectedPreferredProviders] = useState(optionsPreferredProviders);

  // calendar dates
  const [startDateRange, setStartDateRange] = useState(() => moment());

  let error = schedulerData?.getSchedulerData?.errorMessage;
  const defaultErrorMessage = 'Something went wrong please try again';

  if (schedulerDataError && !error) {
    error = defaultErrorMessage;
  }

  // logging
  // total number of unique visits/timeslots selected during the scheduling process.
  const [totalNumberOfPicks, setTotalNumberOfPicks] = useState(new Set([]));

  const [toggleAverageOptions, setToggleAverageOptions] = useState(false);
  const [toggleWorstOptions, setToggleWorstOptions] = useState(false);
  const [calendarView, setCalendarView] = useState<'week' | 'month'>('month');

  const { addNotice, addAlert } = useFlashToast();

  const schedulingStartedAt = useMemo(() => formatUtc(moment()), []);

  const submitVisit = async ({ serviceInstructions }) => {
    if (!selectedVisit) {
      return;
    }

    const {
      rank,
      expected_drive,
      start_time,
      end_time,
      fp_id,
      fp_name,
      total_score,
      drive_score,
      proximity_score,
      utilization_score,
      run_id,
      resources,
    } = selectedVisit;

    const rank_category_chosen = selectedVisit?.rank_category;

    // TODO: scheduler log string should come straight from back end
    const logString = JSON.stringify({
      picks_before_booking: totalNumberOfPicks.size,
      index_chosen: rank,
      drive_time_chosen: expected_drive,
      start_time_chosen: start_time,
      end_time_chosen: end_time,
      field_provider_name: fp_name,
      total_score,
      drive_score,
      proximity_score,
      utilization_score,
      rank_category_chosen,
    });

    const formatted_resources = resources.map(function (resource) {
      return {
        resourceId: resource.resource_id,
        startTime: resource.start_time,
        endTime: resource.end_time,
        inHome: resource.in_home,
      };
    });

    const { data } = await gqlCreateFunc({
      variables: {
        visitParams: {
          patientId: patient?.id?.toString(),
          fieldProviderExternalId: fp_id,
          programId: currentProgramId,
          visitTypeId: currentVisitTypeId,
          serviceIds: formattedServiceIds,
          startTime: start_time,
          endTime: end_time,
          serviceInstructions,
          resources: formatted_resources,
        },
        runId: run_id,
        logString,
        schedulingStartedAt,
      },
    });

    if (data.createAlayacareVisit.visitId) {
      onSuccess(data.createAlayacareVisit.visitId);
    } else {
      addAlert(`Error: ${data.createAlayacareVisit.errors.join(', ')}`);
    }
  };

  const onSuccess = async (visitId: string) => {
    addNotice('Visit scheduled successfully.');

    // If inside an iframe, send visit payload to the parent window
    // Otherwise, redirect to the appropriate page

    if (iframe) {
      const res = await gqlOnSuccessFunc({
        variables: {
          id: visitId,
        },
      });
      const message = {
        type: 'ma:schedulerSuccess',
        data: res.data.getVisit,
      };
      window.parent.postMessage(JSON.stringify(message), '*');
    } else {
      window.location.assign(
        isFieldAccount()
          ? field_patient_path(patient?.id, {
              added_visit_id: visitId,
            })
          : admin_patient_path(patient?.id, {
              added_visit_id: visitId,
            }),
      );
    }
  };

  const timezone = patient?.address?.timezone;

  const firstVisitFilterAttempt = useRef(false);

  const appointmentsCacheKey = suggestedOptions.map(apptId).join();
  const calendarEvents: MbscCalendarEventData[] = useMemo(() => {
    if (!suggestedOptions.length) {
      return [];
    }

    const getFilteredVisits = (averageFilter: boolean, worstFilter: boolean) => {
      // FILTER VISITS
      let options = suggestedOptions;

      let filters = [VISIT_RANK_CATEGORIES.BEST];
      if (averageFilter) {
        filters = [...filters, VISIT_RANK_CATEGORIES.AVERAGE];
      }
      if (worstFilter) {
        filters = [...filters, VISIT_RANK_CATEGORIES.WORST];
      }

      // filter visits by rank categories
      options = options.filter((o) => filters.includes(o.rank_category));

      // get preferred providers or default to all?
      let optionsPreferred = selectedPreferredProviders.length ? selectedPreferredProviders : optionsPreferredProviders;
      optionsPreferred = optionsPreferred?.filter((o) => o.checked === 'on');

      // If any selected preferred providers, filter by them
      const countBeforePreferredFilter = options.length;
      if (optionsPreferred?.length) {
        options = options.filter((o) =>
          every(optionsPreferred, (d) => o.resources.map((r) => r.resource_id).includes(d.value)),
        );
      }
      const countAfterPreferredFilter = options.length;

      return {
        options: options.map(eventFormatter),
        preferredFilterWarning: countBeforePreferredFilter > 0 && countAfterPreferredFilter === 0,
      };
    };

    // On first load, if there are visits but all were filtered out,
    // show yellow visits; if still nothing to show, show red visits
    // If eventually successful in showing visits, check appropriate checkboxes too
    let filterResult = getFilteredVisits(toggleAverageOptions, toggleWorstOptions);
    if (!firstVisitFilterAttempt.current) {
      if (!filterResult.options.length && !toggleAverageOptions) {
        filterResult = getFilteredVisits(true, toggleWorstOptions);
        if (filterResult.options.length) {
          setToggleAverageOptions(true);
        } else if (!toggleWorstOptions) {
          filterResult = getFilteredVisits(true, true);
          if (filterResult.options.length) {
            setToggleAverageOptions(true);
            setToggleWorstOptions(true);
          }
        }
      }

      firstVisitFilterAttempt.current = true;
    }

    setPreferredProviderFilterWarning(filterResult.preferredFilterWarning);
    return filterResult.options;
  }, [JSON.stringify(selectedPreferredProviders), appointmentsCacheKey, toggleAverageOptions, toggleWorstOptions]);

  useEffect(() => {
    if (suggestedOptions.length === 0) {
      return;
    }

    // On visits load, if there are no green visits, select yellow filter
    // If there are no yellow visits, select red filter
    if (!suggestedOptions.some(({ rank_category }) => rank_category === VISIT_RANK_CATEGORIES.BEST)) {
      setToggleAverageOptions(true);

      if (!suggestedOptions.some(({ rank_category }) => rank_category === VISIT_RANK_CATEGORIES.AVERAGE)) {
        setToggleWorstOptions(true);
      }
    }
  }, [appointmentsCacheKey]);

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
      return;
    }
    const newVisit: any = find(suggestedOptions, (v) => apptId(v) === calendarVisitId);
    setSelectedVisit(newVisit);
    setTotalNumberOfPicks(totalNumberOfPicks.add(visit.id));
  };

  const onPageChange = async (e) => {
    const startDate = moment(e.month);
    setStartDateRange(startDate);
  };

  const renderVisit = (event) => {
    const selectedVisitId = selectedVisit ? apptId(selectedVisit) : null;
    const calendarVisitId = apptId(event?.original);
    const scheduledVisitId = scheduledVisit ? apptId(scheduledVisit) : null;
    const isSlotSelected = selectedVisitId === calendarVisitId;
    const isScheduledVisit = scheduledVisitId === calendarVisitId;
    return <VisitSlot event={event} selected={isSlotSelected} scheduledVisit={isScheduledVisit} timezone={timezone} />;
  };

  const customWithNavButtons = () => {
    return <CalendarCustomHeader date={startDateRange} />;
  };

  const isFieldAccount = () => {
    return current_user?.account_type === 'FieldProvider' || current_user?.account_type === 'ExternalAccount';
  };

  const patientPagePath = () => {
    if (isFieldAccount()) {
      return field_patient_path(patient?.id);
    } else {
      return admin_patient_path(patient?.id);
    }
  };

  const patientListPagePath = () => {
    if (isFieldAccount()) {
      return field_patients_path();
    } else {
      return admin_patients_path();
    }
  };

  const breadcrumbs = [
    {
      text: 'Patients',
      href: patientListPagePath(),
    },
    {
      text: patient ? `${patient.first_name} ${patient.last_name}` : '...',
      href: patient ? patientPagePath() : '/',
    },
    {
      text: 'Add Visit',
      href: '#',
      onClick: (e) => {
        e.preventDefault();
      },
    },
  ];

  const onRescheduleVisit = async ({ serviceInstructions, visit }) => {
    if (!selectedVisit) {
      return;
    }

    const {
      rank,
      expected_drive,
      start_time,
      end_time,
      fp_name,
      total_score,
      drive_score,
      proximity_score,
      utilization_score,
      run_id,
      resources,
    } = selectedVisit;

    const rank_category_chosen = selectedVisit?.rank_category;

    // TODO: scheduler log string should come straight from back end
    const logString = JSON.stringify({
      picks_before_booking: totalNumberOfPicks.size,
      index_chosen: rank,
      drive_time_chosen: expected_drive,
      start_time_chosen: start_time,
      end_time_chosen: end_time,
      field_provider_name: fp_name,
      total_score,
      drive_score,
      proximity_score,
      utilization_score,
      rank_category_chosen,
    });

    const formatted_resources = resources.map(function (resource) {
      return {
        resourceId: resource.resource_id,
        startTime: resource.start_time,
        endTime: resource.end_time,
        inHome: resource.in_home,
      };
    });

    if (visit && visit?.canceled) {
      const { data } = await gqlRescheduleVisit({
        variables: {
          visitParams: {
            alayacareVisitId: existingVisitAlayacareId,
            externalId,
            fieldProviderId: selectedVisit?.fp_id,
            patientId: patient?.id?.toString(),
            startTime: start_time,
            endTime: end_time,
            serviceInstructions,
            resources: formatted_resources,
          },
          runId: run_id,
          logString,
        },
      });

      if (data.rescheduleVisit.visitId) {
        onSuccess(data.rescheduleVisit.visitId);
      } else {
        addAlert(`Error: ${data.rescheduleVisit.errors.join(', ')}`);
      }
      return;
    }

    const { data } = await gqlUpdateFunc({
      variables: {
        visitParams: {
          alayacareVisitId: existingVisitAlayacareId,
          externalId,
          fieldProviderId: selectedVisit?.fp_id,
          patientId: patient?.id?.toString(),
          startTime: start_time,
          endTime: end_time,
          serviceInstructions,
          resources: formatted_resources,
          visitTypeId: currentVisitTypeId,
          serviceIds: formattedServiceIds,
        },
        runId: run_id,
        logString,
      },
    });

    if (data.alayacareUpdateVisit.visit?.id) {
      onSuccess(data.alayacareUpdateVisit.visit.id);
    } else {
      addAlert(`Error: ${data.alayacareUpdateVisit.errors.join(', ')}`);
    }
  };

  return (
    <div>
      <EuiPageContent>
        {!iframe && (
          <>
            <EuiBreadcrumbs breadcrumbs={breadcrumbs} truncate={false} />
            <EuiSpacer size="l" />
          </>
        )}
        {isEditModalOpen && (
          <CreateVisitModal
            programs={(programs as unknown) as Program[]}
            closeModal={keepEditModalOpen ? () => null : () => setIsEditModalOpen(false)}
            patient={(patient as unknown) as Patient}
            editWarning={!keepEditModalOpen}
            selectedProgramId={currentProgramId}
            selectedVisitTypeId={currentVisitTypeId}
            currentServiceIds={currentServiceIds}
            redirectPath={modalRedirectPath}
            current_user={current_user}
            serviceRequests={serviceRequests}
          />
        )}

        <EuiFlexGroup alignItems="center" gutterSize="xl" style={{ marginBottom: 20 }} wrap responsive={false}>
          <EuiFlexItem grow={false}>
            <EuiTitle size="s">
              <h1>Add Visit</h1>
            </EuiTitle>
          </EuiFlexItem>
        </EuiFlexGroup>
        <EuiPageContentBody>
          <EuiFlexGroup gutterSize="l">
            <EuiFlexItem style={{ maxWidth: '293px' }}>
              <MedToggleButton
                isSelected
                leftBorderColor="#00BFB3"
                backgroundColor="#E6F9F7"
                title="Most efficient route"
                iconName="faceHappy"
                description="Offer these first"
                isDisabled
              />
            </EuiFlexItem>
            <EuiFlexItem style={{ maxWidth: '293px' }}>
              <MedToggleButton
                isSelected={toggleAverageOptions}
                backgroundColor="#FFF9E8"
                leftBorderColor="#FEC514"
                title="Somewhat efficient route"
                iconName="faceNeutral"
                description="Offer if none of the best options work"
                onClick={() => {
                  setToggleAverageOptions((isOn) => !isOn);
                }}
              />
            </EuiFlexItem>
            <EuiFlexItem style={{ maxWidth: '293px' }}>
              <MedToggleButton
                isSelected={toggleWorstOptions}
                backgroundColor="#F8E9E9"
                leftBorderColor="#BD271E"
                title="Least efficient route"
                iconName="faceSad"
                description="Offer as a last option for the patient"
                onClick={() => {
                  setToggleWorstOptions((isOn) => !isOn);
                }}
              />
            </EuiFlexItem>
            <EuiFlexItem style={{ maxWidth: 'min-content', justifyContent: 'flex-end' }}>
              <FilterPreferredProviders
                items={selectedPreferredProviders.length ? selectedPreferredProviders : optionsPreferredProviders}
                setItems={setSelectedPreferredProviders}
                isLoading={isLoadingPreferred || loadingSchedulerData}
              />
            </EuiFlexItem>
          </EuiFlexGroup>
          <EuiFlexGroup style={{ minHeight: '800px' }}>
            <EuiFlexItem>
              {error && <EuiCallOut size="s" color="danger" title={error} />}
              {preferredProviderFilterWarning && (
                <EuiCallOut size="s" color="warning" title="No slots available which include all selected providers." />
              )}
              {!error && !loadingSchedulerData && suggestedOptions?.length === 0 && (
                <EuiText>
                  <p>No availability found.</p>
                  <EuiSpacer size="l" />
                </EuiText>
              )}
              {loadingSchedulerData && (
                <EuiFlexGroup alignItems="center" style={{ height: 50, marginTop: '0.5rem', marginBottom: '0.5rem' }}>
                  <EuiLoadingSpinner style={{ marginLeft: '1rem' }} size="l" />
                  <EuiText style={{ fontSize: '12px', marginLeft: '1rem', display: 'inline-block' }}>
                    Loading more visits, please wait ...
                  </EuiText>
                </EuiFlexGroup>
              )}
              <MedEventcalendar
                view={{
                  calendar: { type: calendarView, size: 1, labels: 5 },
                }}
                data={calendarEvents}
                selectedDate={calendarEvents[0]?.start || moment()}
                onSelectedDateChange={() => {
                  return;
                }}
                className="scheduler-calendar"
                dataTimezone="utc"
                renderLabel={renderVisit}
                renderEventContent={renderVisit} /* for rendering inside X More popup do not remove */
                renderHeader={customWithNavButtons}
                displayTimezone={timezone}
                timezonePlugin={momentTimezone}
                onEventClick={onEventClick}
                onPageChange={onPageChange}
                themeVariant="light"
              />
              <EuiSpacer size="l" />
            </EuiFlexItem>
            {patient?.id && (
              <div style={{ marginTop: '12px', display: 'flex' }}>
                <VisitSidePanel
                  setIsEditModalOpen={setIsEditModalOpen}
                  duration={currentDuration?.toString()}
                  currentUser={current_user}
                  program={(currentProgram as unknown) as Program}
                  services={currentServices}
                  visitType={currentVisitType}
                  existingVisitAlayacareId={parseInt(existingVisitAlayacareId, 10)}
                  patient={(patient as unknown) as Patient}
                  selectedVisit={selectedVisit}
                  timezone={timezone}
                  onSubmit={submitVisit}
                  disableSubmit={
                    gqlCreateLoading ||
                    gqlCreateSuccess ||
                    gqlUpdateSuccess ||
                    gqlUpdateLoading ||
                    gqlRescheduleLoading ||
                    gqlRescheduleSuccess
                  }
                  onBackButton={() => setSelectedVisit(null)}
                  isScheduled={!!scheduledVisit}
                  externalId={externalId}
                  onRescheduleVisit={onRescheduleVisit}
                  isFieldLayout={isFieldAccount()}
                  errorMessage={!!error}
                />
              </div>
            )}
          </EuiFlexGroup>
        </EuiPageContentBody>
      </EuiPageContent>
    </div>
  );
};

export const FieldScheduleVisitPage = withFieldLayout(ScheduleVisitPageComponent);
export const ScheduleVisitPage = withAdminLayout(ScheduleVisitPageComponent);
