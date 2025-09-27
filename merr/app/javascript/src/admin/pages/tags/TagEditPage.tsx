import React from 'react';
import { EuiPageHeader, EuiPageHeaderSection, EuiPanel, EuiTitle, EuiButton, EuiSpacer } from '@elastic/eui';

import { AdminLayout, AdminPageProps, withAdminLayout } from '@/admin/components/AdminLayout/AdminLayout';
import { Tag } from '@/common/types';
import { formatDate, TIME_FORMAT } from '@/common/utils/dates/dates';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import { useForm } from 'react-hook-form';
import { TagForm } from './TagForm';

type TagEditPageProps = {
  tag: Tag;
};

export const TagEditPageComponent: React.FC<TagEditPageProps> = ({ tag }) => {
  const { id, updated_at } = tag;

  const form = useForm({
    defaultValues: {
      tag,
    },
  });

  const targetUrl = id ? `/admin/tags/${id}` : `/admin/tags`;
  const targetMethod = id ? 'put' : 'post';

  return (
    <>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <span>{id ? 'Edit' : 'New'} Tag</span>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          <EuiButton style={{ border: 'solid 1px #d3dae6' }} color="text" href={`/admin/tags/${id}`}>
            Cancel
          </EuiButton>
        </EuiPageHeaderSection>
      </EuiPageHeader>
      <EuiPanel>
        <SyncForm form={form} url={targetUrl} method={targetMethod}>
          <EuiSpacer size="m" />
          <EuiTitle size="xs">
            <span style={{ fontWeight: 'normal' }}>
              {updated_at &&
                `Last updated ${formatDate(updated_at, 'MMMM Do, YYYY')} at ${formatDate(updated_at, TIME_FORMAT)}`}
            </span>
          </EuiTitle>
          <EuiSpacer size="m" />

          <TagForm cancel={targetUrl} />
        </SyncForm>
      </EuiPanel>
    </>
  );
};

export const TagEditPage = withAdminLayout(TagEditPageComponent);
