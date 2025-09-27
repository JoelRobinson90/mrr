import React, { FC } from 'react';
import { EuiTitle, EuiPageContent, EuiPageContentHeader, EuiPageContentBody, EuiSpacer, EuiText } from '@elastic/eui';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { PaginationParams, usePagination } from '@/common/hooks/usePagination/usePagination';
import { PaginationFooter } from '@/common/components/PaginationFooter/PaginationFooter';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { MedBadge } from '@/common/components/MedBadge/MedBadge';
import { BackgroundJobResults } from '@/common/types';

interface BackgroundJobResultsPageProps extends AdminPageProps {
  background_job_results: BackgroundJobResults[];
  queue_size: number;
  queue_errors: number;
  pagination: PaginationParams;
}

const colorsStatus = {
  succeeded: '#00b38f',
  failed: '#cb3072',
  pending: '#9aa2b2',
};

const columns = [
  {
    field: 'label',
    name: 'Label',
  },
  {
    field: 'humanized_job_type',
    name: 'Job Type',
  },
  {
    field: 'status',
    name: 'Status',
    render: (status) => {
      return <MedBadge color={colorsStatus[status]} text={status} />;
    },
  },
  {
    field: 'message',
    name: 'Message',
  },
  {
    field: 'error_list',
    name: 'Error List',
    render: (error_list) => {
      return (
        <div style={{ flexDirection: 'column', maxHeight: '300px', overflowY: 'scroll' }}>
          {error_list?.map((error) => (
            <EuiText key={error} style={{ display: 'block', marginBottom: '0.5rem' }}>
              {error}
            </EuiText>
          ))}
        </div>
      );
    },
  },
  {
    field: 'date',
    name: 'Created At',
  },
];

export const BackgroundJobResultsIndexPage: FC<BackgroundJobResultsPageProps> = ({
  layout_props,
  pagination,
  background_job_results,
  queue_size,
  queue_errors,
}) => {
  const paginationProps = usePagination(pagination);

  return (
    <AdminLayout {...layout_props}>
      <EuiPageContent>
        <EuiPageContentHeader>
          <EuiTitle>
            <h2>Background Job Results</h2>
          </EuiTitle>
        </EuiPageContentHeader>
        <EuiSpacer size="m" />

        <EuiPageContentBody>
          <a href="/delayed_job/overview">{queue_size} items queued. {queue_errors} queue errors.</a>
          <MedTable items={background_job_results} columns={columns} />
          <PaginationFooter {...paginationProps} />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
