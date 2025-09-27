import React from 'react';
import {
  EuiPageContent,
  EuiPageContentHeader,
  EuiTitle,
  EuiPageContentBody,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiPageContentHeaderSection,
} from '@elastic/eui';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import AuditingList from '@/common/components/AuditingList/AuditingList';

interface PatientPageProps extends AdminPageProps {
  history: any;
}

export const PatientHistoryPage: React.FC<PatientPageProps> = ({ layout_props, history: events }) => {
  // TODO: check why history is a string instead of JSON
  events = JSON.parse(events);

  return (
    <div>
      <AdminLayout {...layout_props}>
        <EuiPageHeader style={{ fontFamily: 'Raleway' }}>
          <EuiPageHeaderSection>
            <EuiTitle size="l">
              <h1>Patient History</h1>
            </EuiTitle>
          </EuiPageHeaderSection>
        </EuiPageHeader>
        <EuiPageContent
          style={{
            backgroundColor: '#ffffff',
            border: 'solid 1px #d3dae6',
            fontFamily: 'Raleway',
          }}
        >
          <EuiPageContentHeader>
            <EuiPageContentHeaderSection>
              <EuiTitle>
                <h2>History</h2>
              </EuiTitle>
            </EuiPageContentHeaderSection>
          </EuiPageContentHeader>
          <EuiPageContentBody>
            <AuditingList
              patient={{ id: 1, medical_record_number: '123', first_name: 'test', last_name: 'test' }}
              events={events}
            />
          </EuiPageContentBody>
        </EuiPageContent>
      </AdminLayout>
    </div>
  );
};
