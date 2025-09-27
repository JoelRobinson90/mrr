import {
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageHeader,
  EuiButton,
  EuiPageContent,
  EuiPageHeaderSection,
  EuiTitle,
  EuiFilterGroup,
} from '@elastic/eui';
import React, { useMemo, useState } from 'react';
import queryString from 'query-string';

import { InviteFieldOrgUserFlyout } from './InviteFieldOrgUserFlyout';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { FilterSelect } from '@/admin/components/FilterSelect/FilterSelect';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { FieldOrg } from '@/common/types';

interface FieldOrgShowPageProps extends AdminPageProps {
  field_org: FieldOrg;
  account_type_filter: string;
  invited_filter?: boolean;
  readable_account_types: string[];
  creatable_account_types: string[];
}

export const FieldOrgShowPage: React.FC<FieldOrgShowPageProps> = ({
  layout_props,
  field_org,
  invited_filter,
  account_type_filter,
  readable_account_types,
  creatable_account_types,
}) => {
  const [inviteFlyoutVisible, setInviteFlyoutVisible] = useState(false);

  let flyout;
  if (inviteFlyoutVisible) {
    flyout = (
      <InviteFieldOrgUserFlyout
        fieldOrg={field_org}
        accountTypes={creatable_account_types}
        onClose={() => setInviteFlyoutVisible(false)}
      />
    );
  }

  const currentParams = useMemo(() => queryString.parse(location.search), []);

  const selectFilter = (param: string, value: number | string) => {
    const newParams = { ...currentParams, [param]: value };
    const url = queryString.stringifyUrl({ url: location.pathname, query: newParams }, { skipNull: true });
    location.assign(url);
  };

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader style={{ fontFamily: 'Raleway', flexDirection: 'row' }}>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Organizations</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          {creatable_account_types.length ? (
            <EuiButton onClick={() => setInviteFlyoutVisible(true)} color="ghost" size="m" fill>
              Invite Users
            </EuiButton>
          ) : null}
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>{field_org.name}</h2>
          </EuiTitle>
        </EuiPageContentHeader>

        <EuiPageContentBody>
          <EuiFilterGroup>
            <FilterSelect
              options={readable_account_types.map((type) => ({ text: type, value: type }))}
              selectedValue={account_type_filter}
              onSelect={(val) => selectFilter('account_type', val)}
            />
            <FilterSelect
              options={[
                { text: 'Active Users', value: 'false' },
                { text: 'Invited Users', value: 'true' },
              ]}
              selectedValue={Boolean(invited_filter).toString()}
              onSelect={(val) => selectFilter('invited', val)}
            />
          </EuiFilterGroup>
          <MedTable
            items={field_org.accounts}
            columns={[
              {
                field: 'user.id',
                name: 'ID',
                width: '60px',
              },
              {
                field: 'display_name',
                name: 'Name',
              },
              {
                field: 'user.email',
                name: 'Email',
              },
              {
                field: 'phone',
                name: 'Phone',
              },
            ]}
          />
        </EuiPageContentBody>
      </EuiPageContent>
      {flyout}
    </AdminLayout>
  );
};
