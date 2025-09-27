import React from 'react';
import {
  EuiButton,
  EuiHorizontalRule,
  EuiLink,
  EuiPageHeaderSection,
  EuiPageHeader,
  EuiPageContent,
  EuiPageContentBody,
  EuiSpacer,
  EuiTitle,
  EuiIcon,
  EuiText,
} from '@elastic/eui';

import { AdminLayout, AdminPageProps } from '@/admin/components/AdminLayout/AdminLayout';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { PaginationFooter } from '@/common/components/PaginationFooter/PaginationFooter';
import { Tag } from '@/common/types';
import { PaginationParams, usePagination } from '@/common/hooks/usePagination/usePagination';
import { DeleteIconForm } from '@/common/components/DeleteIconForm/DeleteIconForm';
import { RIGHT_ALIGNMENT } from '@elastic/eui/lib/services';
import { admin_tag_path } from '@/common/routes';

export interface TagIndexPageProps extends AdminPageProps {
  tags: Tag[];
  pagination: PaginationParams;
  group: string;
}

const columns = [
  {
    field: 'name',
    name: 'Name',
    render: (_, { name, id }) => {
      return (
        <EuiLink style={{ color: '#223A73', textDecoration: 'none' }} href={`/admin/tags/${id}`}>
          {name}
        </EuiLink>
      );
    },
  },
  {
    field: 'color',
    name: 'Color',
    render: (color) => (
      <>
        <EuiIcon type="stopFilled" color={color} />
        <EuiText>{color}</EuiText>
      </>
    ),
  },
  {
    field: 'description',
    name: 'Description',
  },
  {
    field: 'group',
    name: 'Can be used on',
  },
  {
    field: 'taggings_count',
    name: 'Number of uses',
  },
  {
    field: 'delete',
    name: '',
    align: RIGHT_ALIGNMENT,
    render: (_, { id, name }) => {
      return (
        <DeleteIconForm
          id={id}
          confirmationMessage={`Are you sure you want to delete tag - ${name} ?`}
          url={admin_tag_path(id)}
        />
      );
    },
  },
];

export const TagIndexPage: React.FC<TagIndexPageProps> = ({ layout_props, pagination, tags, group }) => {
  const paginationProps = usePagination(pagination);

  return (
    <AdminLayout {...layout_props}>
      <EuiPageHeader>
        <EuiPageHeaderSection>
          <EuiTitle size="l">
            <h1>{group} Tags</h1>
          </EuiTitle>
        </EuiPageHeaderSection>
        <EuiPageHeaderSection>
          <EuiButton href="/admin/tags/new" fill color="ghost" size="m">
            New {group} Tag
          </EuiButton>
        </EuiPageHeaderSection>
      </EuiPageHeader>

      <EuiPageContent>
        <EuiPageContentBody>
          <p>View tags below</p>
          <EuiSpacer size="m" />
          <EuiSpacer size="m" />
          <EuiHorizontalRule margin="s" />
          <EuiSpacer size="m" />
        </EuiPageContentBody>

        <EuiPageContentBody>
          <MedTable items={tags} columns={columns} style={{ color: '#343741' }} />

          <PaginationFooter {...paginationProps} />
        </EuiPageContentBody>
      </EuiPageContent>
    </AdminLayout>
  );
};
