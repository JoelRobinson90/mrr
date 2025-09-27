import { MedSelect, MedTextArea } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { FieldOrg } from '@/common/types';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiFlexGroup,
  EuiFlexItem,
  EuiFlyout,
  EuiFlyoutBody,
  EuiFlyoutFooter,
  EuiFlyoutHeader,
  EuiTitle,
} from '@elastic/eui';
import React from 'react';

interface InviteFieldOrgUserFlyoutProps {
  fieldOrg: FieldOrg;
  accountTypes: string[];
  onClose: () => void;
}

export const InviteFieldOrgUserFlyout: React.FC<InviteFieldOrgUserFlyoutProps> = ({
  fieldOrg,
  accountTypes,
  onClose,
}) => {
  if (accountTypes.length === 0) {
    return null;
  }

  const { id, name } = fieldOrg;

  const roles = accountTypes.map((type) => ({
    value: type,
    text: type,
  }));

  return (
    <EuiFlyout ownFocus onClose={onClose}>
      <SyncForm url={`/admin/field_orgs/${id}/invite_users`} method="post">
        <EuiFlyoutHeader hasBorder>
          <EuiTitle size="m">
            <h2>Invite {name} Users</h2>
          </EuiTitle>
        </EuiFlyoutHeader>
        <EuiFlyoutBody>
          <MedSelect name="account_type" label="User Role" options={roles} />
          <MedTextArea name="emails" label="Emails" helpText="Email addresses separated by commas" />
        </EuiFlyoutBody>

        <EuiFlyoutFooter>
          <EuiFlexGroup justifyContent="spaceBetween">
            <EuiFlexItem grow={false}>
              <EuiButtonEmpty iconType="cross" onClick={onClose} flush="left">
                Close
              </EuiButtonEmpty>
            </EuiFlexItem>
            <EuiFlexItem grow={false}>
              <EuiButton type="submit" fill>
                Save
              </EuiButton>
            </EuiFlexItem>
          </EuiFlexGroup>
        </EuiFlyoutFooter>
      </SyncForm>
    </EuiFlyout>
  );
};
