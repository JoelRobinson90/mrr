import {
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageHeader,
  EuiPageContent,
  EuiPageHeaderSection,
  EuiTitle,
  EuiSpacer,
} from '@elastic/eui';
import React from 'react';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { DemandPartner } from '@/common/types';

interface DemandPartnerShowPageProps extends AdminPageProps {
  demand_partner: DemandPartner;
}

export const DemandPartnerShowPage: React.FC<DemandPartnerShowPageProps> = ({ layout_props, demand_partner }) => {
  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader style={{ fontFamily: 'Raleway', flexDirection: 'row' }}>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Organizations</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>{demand_partner.name}</h2>
          </EuiTitle>
        </EuiPageContentHeader>

        <EuiPageContentBody>
          <p>SMS templates:</p>
          <EuiSpacer size="m" />
          <EuiSpacer size="m" />
          <MedTable
            items={demand_partner.templates}
            columns={[
              {
                field: 'message_type',
                name: 'Message Type',
              },
              {
                field: 'message_body',
                name: 'Message Body',
              },
            ]}
          />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
