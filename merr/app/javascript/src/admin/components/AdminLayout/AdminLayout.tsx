import React, { createContext, useState } from 'react';
import {
  EuiPage,
  EuiPageBody,
  EuiPageSideBar,
  EuiBreadcrumb,
  EuiCollapsibleNav,
  EuiShowFor,
  EuiButtonEmpty,
} from '@elastic/eui';
import { MedPageHeader } from '@/common/components/MedPageHeader/MedPageHeader';
import { withApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';

import AdminNavigation from '@/admin/components/AdminLayout/components/AdminNavigation';
import { GetCurrentUserQuery, useGetCurrentUserQuery } from '@/generated/graphql';

export type AdminLayoutProps = {
  breadcrumbs?: EuiBreadcrumb[];
  rails_action?: string;
  needs_scheduling_count?: number;
  prospects_count?: number;
  environment?: string;
  hide_layout?: boolean;
};

export type AdminPageProps = {
  layout_props: AdminLayoutProps;
};

export type AdminAppContextValue = {
  currentUser?: GetCurrentUserQuery['getCurrentUser'];
};

export const AdminAppContext = createContext<AdminAppContextValue>(null);

const AdminLayoutComponent: React.FC<AdminLayoutProps> = ({
  children,
  breadcrumbs,
  environment,
  hide_layout = false,
}) => {
  const [navIsOpen, setNavIsOpen] = useState<boolean>(false);

  const { data } = useGetCurrentUserQuery();
  const currentUser = data?.getCurrentUser;
  const userType = currentUser?.account?.__typename;

  const providerValue: AdminAppContextValue = { currentUser };

  if (hide_layout) {
    return <AdminAppContext.Provider value={providerValue}>{children}</AdminAppContext.Provider>;
  }

  return (
    <AdminAppContext.Provider value={providerValue}>
      <MedPageHeader
        breadcrumbs={breadcrumbs}
        userName={currentUser?.displayName}
        openMenu={navIsOpen}
        environment={environment}
        isFieldSite={false}
      />
      <EuiPage style={{ marginTop: navIsOpen && 50 }}>
        <EuiShowFor sizes={['xs', 's']}>
          <EuiCollapsibleNav
            style={{ marginTop: navIsOpen && 50 }}
            isOpen={navIsOpen}
            button={
              <div style={{ borderBottom: 'solid 1px #dfdfdf', marginBottom: 8 }}>
                <EuiButtonEmpty iconType="menu" color="text" onClick={() => setNavIsOpen((isOpen) => !isOpen)} />
              </div>
            }
            onClose={() => setNavIsOpen(false)}
          >
            <div style={{ borderBottom: 'solid 1px #dfdfdf', marginBottom: 8, textAlign: 'right' }}>
              <EuiButtonEmpty
                style={{ backgroundColor: 'transparent' }}
                iconType="cross"
                color="text"
                onClick={() => setNavIsOpen((isOpen) => !isOpen)}
              />
            </div>
            <EuiPageSideBar>
              <AdminNavigation isMobile={true} user_role={userType} />
            </EuiPageSideBar>
          </EuiCollapsibleNav>
        </EuiShowFor>
        <EuiShowFor sizes={['m', 'l', 'xl']}>
          <EuiPageSideBar style={{ zIndex: 0 }}>
            <AdminNavigation isMobile={false} user_role={userType} />
          </EuiPageSideBar>
        </EuiShowFor>
        <EuiPageBody component="div">
          <div style={{ fontFamily: 'Raleway', zIndex: 1 }}>{children}</div>
        </EuiPageBody>
      </EuiPage>
    </AdminAppContext.Provider>
  );
};

export const AdminLayout = withApplicationLayout(AdminLayoutComponent);

type WithAdminLayoutProps = {
  layout_props: AdminLayoutProps;
  [key: string]: any;
};

export const withAdminLayout = (component: React.FC): React.FC<WithAdminLayoutProps> => ({
  layout_props,
  children,
  ...props
}) => <AdminLayout {...layout_props}>{React.createElement(component, props, children)}</AdminLayout>;
