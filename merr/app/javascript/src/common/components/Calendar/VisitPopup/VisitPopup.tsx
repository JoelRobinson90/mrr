import React, { FC, useEffect, useMemo, useState } from 'react';
import { AlayacareVisit } from '@/common/types';
import {
  EuiBetaBadge,
  EuiButtonIcon,
  EuiButton,
  EuiFlexItem,
  EuiSpacer,
  EuiText,
  EuiFlexGroup,
  EuiBadge,
  EuiLoadingSpinner,
} from '@elastic/eui';
import moment from 'moment';
import styled from 'styled-components';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers';
import { useForm } from 'react-hook-form';
import {
  useCreateAlayacareVisitNoteMutation,
  useGetVisitQuery,
  useUpdateAlayacareVisitMutation,
  useCreateVisitGroupMutation,
} from '@/generated/graphql';
import { useFlashToast } from '../../FlashToast/FlashToast';
import {
  admin_capacity_availability_path,
  admin_patient_path,
  field_patient_path,
  field_cancel_visit_partial_path,
  admin_alayacare_cancel_visit_partial_path,
  admin_patient_visits_path,
  field_capacity_availability_path,
  field_patient_visits_path,
} from '@/common/routes';
import { formatDate, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';

import displayStatus from '@/common/utils/statuses/displayStatus';
import { RemotePartial } from '../../RemotePartial/RemotePartial';
import { calculateInfoColor } from '@/common/utils/calendar/utils';
import { VisitPopupActions } from '@/common/components/Calendar/VisitPopup/components/VisitPopupActions';
import { InformationTab } from '@/common/components/Calendar/VisitPopup/components/InformationTab';
import { NotesTab } from '@/common/components/Calendar/VisitPopup/components/NotesTab';

type VisitPopupProps = {
  visit: AlayacareVisit;
  setOpen: (toggle: boolean) => void;
  current_user: any;
  onVisitUpdated?: (visit) => void;
  setEditFlyoutPath?: (visit) => void;
  editFlyoutPath?: string;
  onEditVisit?: any;
};

const PopupContainer = styled.div`
  font-family: Inter;
  background: white;
  width: 100%;
  z-index: 1;
`;

const Actions = styled(EuiFlexItem)`
  position: fixed;
  bottom: 0;
  width: 100%;
`;

const PopupHeader = styled.div`
  color: #1a1c21;
  padding: 17px 20px;
  border-bottom: 1px solid #ccc;
  background-color: white;
  position: fixed;
  z-index: 3;
  width: 100%;
`;

const Title = styled.span`
  color: #1a1c21;
  font-weight: bold;
  padding: 20px;
`;

export const VisitPopup: FC<VisitPopupProps> = ({ visit, setOpen, current_user, onVisitUpdated, onEditVisit }) => {
  if (!visit) {
    return null;
  }

  /* State Block Start */
  const [selectedPatientOptions, setSelectedPatient] = useState([]);
  const [visitNotes, setVisitNotes] = useState([]);
  const [isAddingNote, setIsAddingNote] = useState(false);
  const [selectedTab, setSelectedTab] = useState('information');
  const [isAddingPatient, setIsAddingPatient] = useState(false);
  const [cancelFlyoutPath, setCancelFlyoutPath] = useState<string | null>(null);
  const [justAddedPlusOne, setJustAddedPlusOne] = useState(false); // This is a bit hacky, but it's the fastest solution--when we move to a graph call for visits, this can die
  /* State Block End */

  const patient = visit?.patient;

  const isAdmin =
    current_user?.account_type === 'MedarriveAdmin' ||
    current_user?.account_type === 'MedarriveCustomerSupport' ||
    current_user?.account_type == 'MedarriveClinicalOperation';

  const isFieldAccount = ['FieldProvider', 'ExternalAccount'].includes(current_user?.account_type);

  const [gqlCreateVisitNote, { loading: gqlCreateVisitNoteLoading }] = useCreateAlayacareVisitNoteMutation();

  const { refetch: refetchVisitData, data: visitDataFetched, loading: loadingVisitData } = useGetVisitQuery({
    variables: {
      alayacare_visit_id: parseInt(visit?.alayacare_visit_id, 10),
      visit_id: visit?.visit_id || '',
    },
    fetchPolicy: 'no-cache',
  });

  const [visitGroupGqlCreateFunc] = useCreateVisitGroupMutation();

  // restart selected tab when switching visit
  useEffect(() => {
    refetchVisitData();
    setSelectedTab('information');
  }, [visit?.visit_id, isAddingPatient]);

  useEffect(() => {
    setVisitNotes(visitDataFetched?.getVisit?.notes || visitDataFetched?.getVisit?.adminNotes || []);
  }, [visitDataFetched?.getVisit?.id]);

  const { addNotice, addAlert } = useFlashToast();

  const clockIn = visit.clock_in
    ? `${formatDate(visit.clock_in, TIME_FORMAT_WITH_ZONE, patient?.address?.timezone)}`
    : null;
  const clockOut = visit.clock_out
    ? `${formatDate(visit.clock_out, TIME_FORMAT_WITH_ZONE, patient?.address?.timezone)}`
    : null;

  const onRescheduleVisit = (limitArrivalWindow: boolean, ignoreExistingVisitConflicts: boolean) => {
    const visitTypeId = visit?.visit_type?.id;
    const programId = visit?.program?.id;
    const duration = moment(visit.cx_end).diff(moment(visit.cx_start), 'minutes');
    const serviceIds = visit?.services?.map((v) => `service_${v.id}`).join(',');
    const patient = visit?.patient;

    const link = isAdmin ? admin_patient_visits_path : field_patient_visits_path;

    const url = link(patient.id, {
      program_id: programId,
      visit_type_id: visitTypeId,
      duration,
      service_ids: serviceIds,
      existing_visit_alayacare_id: visit.alayacare_visit_id,
      external_id: visit?.visit_id,
      fp_id: visit?.fp_id,
      limit_arrival_window: limitArrivalWindow,
      ignore_existing_visit_conflicts: ignoreExistingVisitConflicts,
    });

    window.location.assign(url);
  };

  /* Notes stuff -- can't move to dedicated NotesTab component until update to graphql */

  const defaultValues = {
    admin_note: {
      current_user_id: current_user?.id,
      content: '',
      alayacare_visit_id: visit.alayacare_visit_id,
      patient_id: visit?.patient?.id,
    },
  };

  const noteSchema = yup.object().shape({
    admin_note: yup.object().shape({
      content: yup.string().label('Content').required(),
    }),
  });

  const form = useForm({
    defaultValues,
    resolver: yupResolver(noteSchema),
  });

  const fetchVisitDataAfterUpdate = async () => {
    const { data: latestVisitData } = await refetchVisitData();

    if (!latestVisitData) {
      // nothing to update
      return;
    }
    const { getVisit } = latestVisitData;

    if (onVisitUpdated && getVisit) {
      onVisitUpdated({ visit_id: getVisit.id, notes: getVisit.notes });
    }
  };

  const createNote = async () => {
    if (!form.getValues('admin_note.content')) {
      addAlert("Note can't be blank");
      return;
    }
    const { data } = await gqlCreateVisitNote({
      variables: {
        visitNoteParams: {
          currentUserId: current_user?.id,
          content: form.getValues('admin_note.content'),
          visitId: `${visit.visit_id}`,
        },
      },
    });

    if (data?.createAlayacareVisitNote?.errors?.length) {
      addAlert(`Error: ${data.createAlayacareVisitNote.errors.join(', ')}`);
    } else {
      addNotice('Visit Note was created successfully!');
      const lastVisitNote = data.createAlayacareVisitNote.visitNote;

      setVisitNotes([
        {
          createdAt: lastVisitNote.createdAt,
          text: lastVisitNote.text,
          creator: {
            displayName: current_user.displayName,
          },
        },
        ...visitNotes,
      ]);
      setIsAddingNote(false);
      fetchVisitDataAfterUpdate();
    }
  };
  /* Notes End */

  const tabs = [
    {
      id: 'information',
      label: 'Information',
      iconType: 'iInCircle',
      onClick: () => {
        setSelectedTab('information');
      },
      content: (
        <InformationTab
          providers={visitDataFetched?.getVisit?.providers}
          onRescheduleVisit={onRescheduleVisit}
          current_user={current_user}
          setIsAddingPatient={setIsAddingPatient}
          isAdmin={isAdmin}
          isAddingPatient={isAddingPatient}
          visitGroup={visitDataFetched?.getVisit?.visitGroup}
          setSelectedPatient={setSelectedPatient}
          selectedOptions={selectedPatientOptions}
          visit={visit}
        />
      ),
    },
    {
      id: 'notes',
      label: (
        <div style={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
          Notes&nbsp;&nbsp;
          {loadingVisitData ? (
            <EuiLoadingSpinner size="m" />
          ) : (
            <EuiBetaBadge size="s" label={visitNotes?.length.toString()} color="subdued" />
          )}
        </div>
      ),
      iconType: 'document',
      onClick: () => {
        setSelectedTab('notes');
      },
      content: (
        <NotesTab
          isAddingNote={isAddingNote}
          setIsAddingNote={setIsAddingNote}
          visitNotes={visitNotes}
          createNote={createNote}
          form={form}
          gqlCreateVisitNoteLoading={gqlCreateVisitNoteLoading}
        />
      ),
    },
  ];

  const selectedTabContent = useMemo(() => tabs.find((t) => t.id === selectedTab)?.content, [
    selectedTab,
    isAddingNote,
    visit,
    isAddingPatient,
    visitDataFetched,
    visitDataFetched?.getVisit?.providers,
    selectedPatientOptions,
  ]);

  const onCancelVisit = (visit: AlayacareVisit) => {
    const patient = visit?.patient;
    setCancelFlyoutPath(
      isFieldAccount
        ? field_cancel_visit_partial_path({
            alayacare_visit_id: visit.alayacare_visit_id,
            visit_id: visit.visit_id,
            patient_id: patient.id,
          })
        : admin_alayacare_cancel_visit_partial_path({
            alayacare_visit_id: visit.alayacare_visit_id,
            visit_id: visit.visit_id,
            patient_id: patient.id,
          }),
    );
  };

  const infoColor = calculateInfoColor(visit);
  const [gqlUpdateFunc] = useUpdateAlayacareVisitMutation();

  const onRevertCancel = async (visit) => {
    if (!visit) {
      return;
    }

    const { data } = await gqlUpdateFunc({
      variables: {
        visitParams: {
          alayacareVisitId: visit.visit_id,
          externalId: visit.visit_id,
          startTime: visit.start_time,
          endTime: visit.end_time,
          patientId: visit?.patient?.id.toString(),
          canceled: false,
          resources: [], // keep old resources
        },
      },
    });
    if (data.alayacareUpdateVisit.visit?.id) {
      addNotice('Visit was uncancelled!');
    } else {
      addAlert(`Error: ${data.alayacareUpdateVisit.errors.join(', ')}`);
    }
    if (window.location.href.includes('capactiy')) {
      const link = isAdmin ? admin_capacity_availability_path : field_capacity_availability_path;
      window.location.href = link();
    } else {
      const link = isAdmin ? admin_patient_path : field_patient_path;
      window.location.href = link(visit.patient.id);
    }
  };

  const onEdit = () => {
    onEditVisit(visit);
    setOpen(false);
  };

  const setBackToBaseline = () => {
    setCancelFlyoutPath(null);
  };

  const visitPopupActions = !!visit && (
    <VisitPopupActions
      isCancelling={cancelFlyoutPath}
      isEditing={false}
      isAddingPatient={isAddingPatient}
      visit={visit}
      setCancelFlyoutPath={setCancelFlyoutPath}
      confirmButtonDisabled
      onEditVisit={onEdit}
      setOpen={setOpen}
      onCancelVisit={(visit) => {
        onCancelVisit(visit);
      }}
      onRescheduleVisit={onRescheduleVisit}
      onRevertCancel={onRevertCancel}
      onConfirmSearch={() => createPlusOneVisit(visit)}
      onCancelSearch={() => setIsAddingPatient(false)}
      onClose={setBackToBaseline}
    />
  );

  const createPlusOneVisit = async (visit) => {
    const patientId = parseInt(selectedPatientOptions[0]?.id);
    const { data: visitGroupData } = await visitGroupGqlCreateFunc({
      variables: {
        patientId: patientId,
        visitId: visit.id,
      },
    });
    setIsAddingPatient(false);
    if (visitGroupData.createVisitGroup.id) {
      setJustAddedPlusOne(true);
      addNotice(`Visit added for ${selectedPatientOptions[0].label}`);
      setSelectedPatient([]);
    } else {
      addAlert(`Oops, that didn't work!`);
    }
  };

  const closePopup = () => {
    setOpen(false);
    setCancelFlyoutPath(null);
  };

  return (
    <div>
      <PopupContainer>
        <PopupHeader>
          <EuiFlexGroup justifyContent="spaceBetween" alignItems="center">
            <Title>Visit Details</Title>
            <EuiFlexGroup gutterSize="s" alignItems="center">
              <EuiFlexItem style={{ maxWidth: '80px' }}>
                <EuiBadge
                  color={infoColor.backgroundColor}
                  style={{ color: infoColor.text, padding: '4px', borderRadius: '4px' }}
                >
                  {visit?.confirmed && displayStatus(visit?.status) === 'Scheduled'
                    ? displayStatus('confirmed')
                    : displayStatus(visit?.status)}
                </EuiBadge>
              </EuiFlexItem>
              {(visit?.visit_group_id || justAddedPlusOne) && (
                <EuiFlexItem style={{ maxWidth: '100px' }}>
                  <EuiBadge color={'#0071C2'} style={{ color: '#E6E6E6', padding: '4px', borderRadius: '4px' }}>
                    Plus One Visit
                  </EuiBadge>
                </EuiFlexItem>
              )}
              <EuiFlexGroup direction="column">
                <EuiFlexItem>
                  {visit.cancelled && (
                    <EuiText style={{ fontSize: '13px', color: 'black' }}>
                      {typeof visit.cancel_code === 'string' ? visit.cancel_code : visit?.cancel_code?.code}
                    </EuiText>
                  )}
                  {clockIn && (
                    <EuiText style={{ fontSize: '13px', color: 'black' }}>
                      <b>Clock In:</b> {clockIn} {clockOut && <b>Clock Out:</b>} {clockOut}
                    </EuiText>
                  )}
                </EuiFlexItem>
              </EuiFlexGroup>
            </EuiFlexGroup>
            <EuiButtonIcon aria-label="Close" iconType="cross" color="text" onClick={closePopup} />
          </EuiFlexGroup>
        </PopupHeader>

        <div style={{ padding: '88px 20px 50px 20px', flexDirection: 'row', display: 'flex' }}>
          {cancelFlyoutPath ? (
            <div style={{ width: '100%', minHeight: '350px' }}>
              <RemotePartial
                path={cancelFlyoutPath}
                partialProps={{
                  redirectPath: window.location.href.includes('capacity')
                    ? admin_capacity_availability_path()
                    : admin_patient_path(patient.id),
                }}
              />
            </div>
          ) : (
            <>
              <div style={{ width: 160 }}>
                {tabs.map((t) => (
                  <div key={t.id}>
                    <EuiButton
                      style={{
                        color: '#343741',
                        borderColor: 'transparent',
                        textDecoration: 'none',
                        boxShadow: 'none',
                        backgroundColor: selectedTab === t.id ? 'rgba(105, 112, 125, 0.1)' : 'inherit',
                        width: '100%',
                      }}
                      color="primary"
                      key={t.iconType}
                      iconType={t.iconType}
                      size="s"
                      fill={selectedTab === t.id}
                      onClick={t.onClick}
                    >
                      {t.label}
                    </EuiButton>
                    <EuiSpacer size="m" />
                  </div>
                ))}
              </div>
              <div style={{ width: '100%', paddingLeft: 16, paddingBottom: 100 }}>{selectedTabContent}</div>
            </>
          )}
        </div>
        <Actions>{visitPopupActions}</Actions>
      </PopupContainer>
    </div>
  );
};
