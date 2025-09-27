import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { FieldOrg } from '@/common/types';
import {
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiTitle,
} from '@elastic/eui';
import React from 'react';

interface FieldOrgIndexPageProps extends AdminPageProps {
  field_orgs: FieldOrg[];
}

export const FieldOrgIndexPage: React.FC<FieldOrgIndexPageProps> = ({ layout_props, field_orgs }) => {
  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Organizations</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>Field Organizations</h2>
          </EuiTitle>
        </EuiPageContentHeader>

        <EuiPageContentBody>
          <MedTable
            items={field_orgs}
            columns={[
              {
                field: 'name',
                name: 'Name',
              },
            ]}
            rowProps={({ id }) => ({ onClick: () => window.location.assign(`/admin/field_orgs/${id}`) })}
          />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
