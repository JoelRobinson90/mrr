import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { DemandPartner } from '@/common/types';
import {
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiTitle,
} from '@elastic/eui';
import React from 'react';

interface DemandPartnerIndexPageProps extends AdminPageProps {
  demand_partners: DemandPartner[];
}

export const DemandPartnerIndexPage: React.FC<DemandPartnerIndexPageProps> = ({ layout_props, demand_partners }) => {
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
            <h2>Demand partners</h2>
          </EuiTitle>
        </EuiPageContentHeader>

        <EuiPageContentBody>
          <MedTable
            items={demand_partners}
            columns={[
              {
                field: 'name',
                name: 'Name',
              },
            ]}
            rowProps={({ id }) => ({ onClick: () => window.location.assign(`/admin/demand_partners/${id}`) })}
          />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
