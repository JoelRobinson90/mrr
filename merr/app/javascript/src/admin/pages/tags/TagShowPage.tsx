import React from 'react';
import {
  EuiSpacer,
  EuiPageHeader,
  EuiPageHeaderSection,
  EuiButton,
  EuiTitle,
  EuiHorizontalRule,
  EuiPanel,
  EuiIcon,
} from '@elastic/eui';

import { Tag } from '@/common/types';
import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { PatientDescription } from '@/admin/pages/appointments/AppointmentShowPage/AppointmentShowPage';

export interface PageProps extends AdminPageProps {
  tag: Tag;
}

export const TagShowPage: React.FC<PageProps> = ({ tag, layout_props }) => {
  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>Tag</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          <EuiButton href={`/admin/tags/${tag.id}/edit`} fill color="ghost" size="m">
            Edit
          </EuiButton>
        </EuiPageHeaderSection>
      </EuiPageHeader>
      <EuiPanel>
        <EuiTitle size="l">
          <span>{tag.name}</span>
        </EuiTitle>
        <EuiHorizontalRule margin="s" />
        <EuiSpacer size="m" />
        <PatientDescription
          title={<b>Color</b>}
          description={
            <span>
              <EuiIcon type="stopFilled" color={tag.color} />
              <span>{tag.color}</span>
            </span>
          }
        />
        <PatientDescription title={<b>Description</b>} description={tag.description} />
        <PatientDescription title={<b>Group</b>} description={tag.group} />
        <PatientDescription title={<b>Uses</b>} description={tag.taggings_count} />
      </EuiPanel>
    </AdminLayout>
  );
};
