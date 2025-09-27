import React from 'react';
import { EuiFlexGroup, EuiFlexItem, EuiIcon, EuiLink, EuiButton } from '@elastic/eui';
import { admin_patient_path, field_patient_path } from '@/common/routes';

interface PlusOneWarningProps {
  visitGroup: any;
  plusOneWarningUnderstood: any;
  setPlusOneWarningUnderstood: Function;
  current_user: any;
  verb: string;
  currentPatientId: any;
}

export const PlusOneWarning: React.FC<PlusOneWarningProps> = ({
  visitGroup,
  plusOneWarningUnderstood,
  setPlusOneWarningUnderstood,
  current_user,
  verb,
  currentPatientId,
}) => {
  // the shape of current user is different in the scheduler than it is in the patient show page
  // this is a catch-all until that can be unified
  const isAdmin =
    current_user?.account?.__typename === 'MedarriveAdmin' ||
    current_user?.account_type === 'MedarriveAdmin' ||
    current_user?.account_type === 'MedarriveCustomerSupport' ||
    current_user?.account?.__typename == 'MedarriveCustomerSupport';

  return (
    <EuiFlexGroup gutterSize="xs" component="div" style={{ marginTop: 10, marginBottom: 10 }} direction="column">
      <EuiFlexGroup gutterSize="xs" component="div" style={{ marginTop: 10, marginBottom: 10 }}>
        <EuiFlexItem grow={false}>
          <EuiIcon size="l" type="alert" color="danger" />
        </EuiFlexItem>
        <EuiFlexItem>
          <div style={{ color: 'black' }}>
            Multiple patients are scheduled for this visit. Continuing will only {verb} the visit for this patient.
            Other patients on this visit are:
            {visitGroup?.visits.map((v) => {
              if (v?.patient?.id.toString() !== currentPatientId.toString()) {
                return (
                  <div key={`w${v?.patient?.id}`} style={{ marginTop: '10px' }}>
                    <EuiLink
                      target="_blank"
                      href={isAdmin ? admin_patient_path(v?.patient?.id) : field_patient_path(v?.patient?.id)}
                    >
                      {v.patient?.first_name} {v.patient?.last_name}
                    </EuiLink>
                  </div>
                );
              }
            })}
          </div>
        </EuiFlexItem>
      </EuiFlexGroup>
      {plusOneWarningUnderstood === false && (
        <EuiButton onClick={() => setPlusOneWarningUnderstood(true)}>I Understand</EuiButton>
      )}
    </EuiFlexGroup>
  );
};
