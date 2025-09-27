import { AlayacareVisit } from '@/common/types';
import { EuiFlexItem, EuiButtonEmpty, EuiButton } from '@elastic/eui';
import React, { FC } from 'react';
import styled from 'styled-components';

interface VisitPopupActionsProps {
  visit: AlayacareVisit;
  onRescheduleVisit: (limitArrivalWindow: boolean, ignoreExistingVisitConflicts: boolean) => void;
  onCancelVisit: (visit: AlayacareVisit) => void;
  onEditVisit: () => void;
  onRevertCancel?: (visit: AlayacareVisit) => void;
  setCancelFlyoutPath?: any;
  onConfirmCancel?: any;
  confirmButtonDisabled?: Boolean;
  setOpen?: any;
  onConfirmSearch?: any;
  onCancelSearch?: any;
  onClose?: any;
  isCancelling?: any;
  isEditing?: any;
  isAddingPatient?: any;
}

const ActionsContainer = styled.div`
  background: white;
  display: flex;
  padding: 1.5rem;
  border-top: 1px solid #ccc;
  justify-content: space-between;
  width: 100%;
`;

export const VisitPopupActions: FC<VisitPopupActionsProps> = ({
  visit,
  onRescheduleVisit,
  onEditVisit,
  onRevertCancel,
  isCancelling,
  onCancelVisit,
  onConfirmCancel,
  confirmButtonDisabled,
  onConfirmSearch,
  onCancelSearch,
  onClose,

  isAddingPatient,
}) => {
  const isCancelled = visit.cancelled || visit.status === 'cancelled';

  const basicActions = (
    <>
      {visit.status !== 'completed' && (
        <EuiFlexItem>
          <EuiButtonEmpty
            size="s"
            onClick={() => {
              onRescheduleVisit(false, true);
            }}
          >
            Reschedule Visit
          </EuiButtonEmpty>
        </EuiFlexItem>
      )}
      <EuiFlexItem>
        <EuiButtonEmpty
          onClick={() => {
            onCancelVisit(visit);
          }}
          size="s"
          aria-label="Cancel Visit"
          color="danger"
        >
          {isCancelled ? 'Edit Cancellation Reason' : 'Cancel Visit'}
        </EuiButtonEmpty>
      </EuiFlexItem>
      {!isCancelled && visit.status !== 'clocked' && (
        <EuiFlexItem>
          <EuiButton
            style={{ backgroundColor: 'rgba(0, 109, 228, 0.2)', border: 'none', color: 'rgba(0, 94, 196, 1)' }}
            fill
            onClick={() => onEditVisit()}
            size="s"
            aria-label="Edit Visit"
            color="primary"
          >
            Edit Info
          </EuiButton>
        </EuiFlexItem>
      )}

      {isCancelled && (
        <EuiFlexItem>
          <EuiButtonEmpty
            onClick={() => {
              onRevertCancel(visit);
            }}
            size="s"
            aria-label="Edit Visit"
            color="primary"
          >
            Undo Cancel
          </EuiButtonEmpty>
        </EuiFlexItem>
      )}
    </>
  );

  const addPatientActions = (
    <>
      <EuiFlexItem>
        <EuiButtonEmpty size="s" onClick={onCancelSearch}>
          Cancel
        </EuiButtonEmpty>
      </EuiFlexItem>
      <EuiFlexItem>
        <EuiButton
          isDisabled={!confirmButtonDisabled}
          style={{
            backgroundColor: confirmButtonDisabled ? 'rgba(0, 109, 228, 0.2)' : '#ABB4C41A',
            border: 'none',
            color: confirmButtonDisabled ? 'rgba(0, 94, 196, 1)' : '#ABB4C4',
          }}
          fill
          onClick={onConfirmSearch}
          size="s"
          aria-label="Edit Visit"
        >
          Confirm
        </EuiButton>
      </EuiFlexItem>
    </>
  );

  const cancelVisitActions = (
    <>
      <EuiFlexItem>
        <EuiButtonEmpty size="s" onClick={onClose}>
          Close
        </EuiButtonEmpty>
      </EuiFlexItem>
      <EuiFlexItem>
        <EuiButton
          isDisabled={!confirmButtonDisabled}
          style={{
            backgroundColor: confirmButtonDisabled ? 'rgba(0, 109, 228, 0.2)' : '#ABB4C41A',
            border: 'none',
            color: confirmButtonDisabled ? 'rgba(0, 94, 196, 1)' : '#ABB4C4',
          }}
          fill
          onClick={onConfirmCancel}
          size="s"
          aria-label="Edit Visit"
          type="submit"
          form="cancelVisitForm"
        >
          Confirm Cancelation
        </EuiButton>
      </EuiFlexItem>
    </>
  );

  return (
    <ActionsContainer>
      <>
        {!isAddingPatient && !isCancelling && basicActions}
        {isCancelling && cancelVisitActions}
        {isAddingPatient && addPatientActions}
      </>
    </ActionsContainer>
  );
};
