import React, { useEffect, useState } from 'react';
import { Patient } from '@/common/types';
import {
  EuiPanel,
  EuiFlexGroup,
  EuiIcon,
  EuiSpacer,
  EuiFlexItem,
  EuiButton,
  EuiModal,
  EuiModalBody,
  EuiModalFooter,
  EuiModalHeader,
  EuiModalHeaderTitle,
  EuiOverlayMask,
  EuiText,
} from '@elastic/eui';
import { formatDate, DATE_WITH_TIME } from '@/common/utils/dates/dates';
import styled from 'styled-components';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers';
import * as yup from 'yup';
import { MedTextArea, MedTextField } from '@/common/components/forms';

interface PatientNotesTabProps {
  patient: Patient;
  current_user: any;
}
export const noteSchema = yup.object().shape({
  admin_note: yup.object().shape({
    content: yup.string().label('Content').required(),
  }),
});

export const PatientNotesTab: React.FC<PatientNotesTabProps> = ({ patient, current_user }) => {
  const ButtonSubmitStyled = styled(EuiButton)`
    background-color: #223e7d !important;
  `;

  const InputHidden = styled(MedTextField)`
    display: none;
  `;

  const defaultValues = {
    admin_note: {
      creator_id: current_user?.id,
      content: '',
    },
  };

  const form = useForm({
    defaultValues,
    resolver: yupResolver(noteSchema),
  });

  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => form.reset(defaultValues), [current_user?.id]);
  return (
    <>
      {isModalOpen && (
        <EuiOverlayMask>
          <EuiModal onClose={() => setIsModalOpen(false)}>
            <SyncForm form={form} url={`/admin/patients/${patient.id}/admin_notes`} method="post">
              <EuiModalHeader>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <EuiModalHeaderTitle style={{ paddingBottom: 8 }}>Add Note</EuiModalHeaderTitle>
                  <div>These notes are only visible to internal users. They cannot be edited or deleted.</div>
                </div>
              </EuiModalHeader>

              <EuiModalBody style={{ paddingTop: 24 }}>
                <InputHidden name="admin_note.creator_id" />
                <MedTextArea name="admin_note.content" style={{ backgroundColor: 'white' }} fullWidth />
              </EuiModalBody>
              <EuiModalFooter>
                <EuiFlexGroup justifyContent="flexEnd" responsive={false}>
                  <EuiFlexItem grow={false}>
                    <EuiButton color="primary" onClick={() => setIsModalOpen(false)}>
                      Cancel
                    </EuiButton>
                  </EuiFlexItem>
                  <EuiFlexItem grow={false}>
                    <EuiButton color="primary" type="submit" fill>
                      Submit
                    </EuiButton>
                  </EuiFlexItem>
                </EuiFlexGroup>
              </EuiModalFooter>
            </SyncForm>
          </EuiModal>
        </EuiOverlayMask>
      )}
      <EuiFlexGroup justifyContent="flexEnd" style={{ marginTop: 25, marginBottom: 15 }}>
        <EuiButton iconType="plusInCircle" onClick={() => setIsModalOpen(true)} style={{ border: 'none' }}>
          Add New
        </EuiButton>
      </EuiFlexGroup>
      <EuiSpacer />

      <div style={{ paddingLeft: 8 }}>
        {patient.admin_notes.map((note) => (
          <div style={{ marginTop: 8 }} key={`${note.id}by${note?.creator?.display_name}`}>
            <EuiFlexGroup justifyContent="flexStart" direction="row">
              <div
                style={{
                  display: 'flex',
                  backgroundColor: '#0071C2',
                  height: 36,
                  width: 36,
                  borderRadius: 18,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
              >
                <EuiIcon color="white" type={'documents'} />
              </div>

              <div style={{ width: '100%', paddingLeft: 8 }}>
                <EuiText style={{ paddingBottom: 8 }}>
                  <h4>Internal Note</h4>
                </EuiText>
                <EuiPanel
                  style={{ minHeight: 112, borderRadius: 6, border: '1px solid #1322951A' }}
                  color="subdued"
                  borderRadius="none"
                  hasShadow={false}
                >
                  <div>{note.content}</div>
                </EuiPanel>
                <EuiFlexGroup justifyContent={'flexEnd'} style={{ paddingTop: 8, paddingBottom: 8, fontSize: 10.5 }}>
                  <EuiFlexItem grow={false}>
                    {note?.creator?.display_name && `created by ${note?.creator?.display_name}`}
                  </EuiFlexItem>
                  <EuiFlexItem grow={false}>{formatDate(note?.created_at, DATE_WITH_TIME)}</EuiFlexItem>
                </EuiFlexGroup>
              </div>
            </EuiFlexGroup>
          </div>
        ))}
      </div>
    </>
  );
};
