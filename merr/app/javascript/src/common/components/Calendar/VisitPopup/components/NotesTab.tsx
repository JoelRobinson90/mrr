import { EuiButtonEmpty, EuiFlexItem, EuiSpacer, EuiText, EuiIcon, EuiPanel, EuiCopy } from '@elastic/eui';
import React, { FC } from 'react';
import { formatDate } from '@/common/utils/dates/dates';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { MedTextArea } from '@/common/components/forms';

interface VisitPopupActionsProps {
  isAddingNote: boolean;
  setIsAddingNote: (boolean) => void;
  visitNotes: { createdAt: string; created_at: string; text: string; creator: { displayName: string } }[];
  form: any;
  createNote: any;
  gqlCreateVisitNoteLoading: any;
}

export const NotesTab: FC<VisitPopupActionsProps> = ({
  isAddingNote,
  setIsAddingNote,
  visitNotes,
  form,
  createNote,
  gqlCreateVisitNoteLoading,
}) => {
  return (
    <div style={{ color: 'black', width: '100%', paddingRight: 12 }}>
      {!isAddingNote && (
        <div
          style={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', flexDirection: 'row', paddingBottom: 4, alignItems: 'center' }}>
            <EuiIcon type="documents" color="primary" style={{ marginRight: 8 }} />
            <EuiText>
              <h4>Visit Notes</h4>
            </EuiText>
          </div>

          <EuiButtonEmpty onClick={() => setIsAddingNote(true)}>Add Note</EuiButtonEmpty>
        </div>
      )}

      {isAddingNote && (
        <SyncForm form={form} url={`/admin/visits`} method="post">
          <div
            style={{
              display: 'flex',
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'spaceBetween',
              width: '100%',
            }}
          >
            <div style={{ display: 'flex', flexDirection: 'row', paddingBottom: 4, alignItems: 'center', flex: 1 }}>
              <EuiIcon type="documents" color="primary" style={{ marginRight: 8 }} />
              <EuiText>
                <h4>Visit Notes</h4>
              </EuiText>
            </div>

            <div
              style={{
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'flex-end',
                alignItems: 'center',
                flex: 1,
              }}
            >
              <EuiFlexItem grow={false}>
                <EuiButtonEmpty color="primary" onClick={() => setIsAddingNote(false)}>
                  Cancel
                </EuiButtonEmpty>
              </EuiFlexItem>
              <EuiFlexItem grow={false}>
                <EuiButtonEmpty disabled={gqlCreateVisitNoteLoading} color="primary" type="button" onClick={createNote}>
                  Save
                </EuiButtonEmpty>
              </EuiFlexItem>
            </div>
          </div>

          <div style={{ padding: '6px 0 26px 0', width: '100%' }}>
            <MedTextArea name="admin_note.content" style={{ backgroundColor: 'white', borderRadius: 6 }} fullWidth />
          </div>
        </SyncForm>
      )}
      {visitNotes?.map(({ createdAt, created_at, text, creator }) => (
        <div key={createdAt}>
          <EuiCopy textToCopy={text} display="block">
            {(copy) => (
              <EuiPanel
                key={created_at}
                onClick={(e) => {
                  copy();
                  e.stopPropagation();
                }}
              >
                {text}
              </EuiPanel>
            )}
          </EuiCopy>
          <div
            style={{
              display: 'flex',
              flexDirection: 'row',
              justifyContent: 'flex-end',
              padding: '4px 0 8px 0',
            }}
          >
            <div style={{ color: '#69707D', fontSize: '11px' }}>
              {creator?.displayName && <span style={{ marginRight: '16px' }}>Created by {creator?.displayName}</span>}
              <span>{formatDate(createdAt, 'DD MMM YYYY, h:mma')}</span>
            </div>
          </div>
          <EuiSpacer size="s" />
        </div>
      ))}
    </div>
  );
};
