import React from 'react';
import { Meta } from '@storybook/react';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { AdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { EuiBadge, EuiPageContent, EuiPageContentBody, EuiPageContentHeader, EuiTitle } from '@elastic/eui';

export default {
  title: 'Components/Pages',
  component: AdminLayout,
} as Meta;

const PatientBadge = (status) => {
  const complete = status.toLowerCase() === 'scheduled' || status.toLowerCase() === 'completed';
  const color = complete ? 'hollow' : '#DD0A73';

  return <EuiBadge color={color}>{status}</EuiBadge>;
};

const MedTableData = {
  items: [
    {
      name: 'Harrison',
      diagnosis: 'Diabetes & 3 Others',
      phoneNumber: '(541) 754-3010',
      location: 'Nairobi, Kenya',
      partner: 'partner-1',
      status: 'Awaiting',
    },
    {
      name: 'Erik',
      diagnosis: 'Diabetes & 3 Others',
      phoneNumber: '(541) 754-3011',
      location: 'Dallas, Texas',
      partner: 'partner-2',
      status: 'Scheduled',
    },
    {
      name: 'Krishna',
      diagnosis: 'Congestive Heart Failure',
      phoneNumber: '(541) 754-3012',
      location: 'New York City, New York',
      partner: 'partner-3',
      status: 'Completed',
    },
    {
      name: 'Soren',
      diagnosis: 'Congestive Heart Failure',
      phoneNumber: '(541) 754-3013',
      location: 'San Francisco, California',
      partner: 'partner-4',
      status: 'Missing Data',
    },
  ],
  columns: [
    {
      field: 'name',
      name: 'Name',
      sortable: true,
    },
    {
      field: 'diagnosis',
      name: 'Diagnosis',
      sortable: true,
    },
    {
      field: 'phoneNumber',
      name: 'Phone Number',
    },
    {
      field: 'location',
      name: 'City / State',
    },
    {
      field: 'partner',
      name: 'Partner',
    },
    {
      field: 'status',
      name: 'Status',
      render: (status) => {
        return PatientBadge(status);
      },
    },
  ],
};

export function AdminPageLayout() {
  return (
    <AdminLayout>
      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>All Patients</h2>
          </EuiTitle>
        </EuiPageContentHeader>
        <EuiPageContentBody>
          <p>Search for patients below:</p>
          <br />
          <br />
          <hr />
          <br />
        </EuiPageContentBody>
        <EuiPageContentBody>
          <MedTable {...MedTableData} />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
}
