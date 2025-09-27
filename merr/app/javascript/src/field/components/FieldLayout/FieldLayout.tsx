import { withApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';
import { MedPageHeader } from '@/common/components/MedPageHeader/MedPageHeader';
import {
  EuiPage,
  EuiPageBody,
  EuiPageContent,
  EuiPageContentBody,
  EuiShowFor,
  EuiCollapsibleNav,
  EuiButtonEmpty,
  EuiPageSideBar,
} from '@elastic/eui';
import React, { useState } from 'react';
import AdminNavigation from '@/admin/components/AdminLayout/components/AdminNavigation';

import { useGetCurrentUserQuery } from '@/generated/graphql';

const FieldLayoutComponent: React.FC = ({ children }) => {
  const [navIsOpen, setNavIsOpen] = useState<boolean>(false);
  const { data } = useGetCurrentUserQuery();
  const currentUser = data?.getCurrentUser;
  const userType = currentUser?.account?.__typename;

  return (
    <>
      <MedPageHeader breadcrumbs={[]} userName={currentUser?.displayName} isFieldSite={true} />
      <EuiPage>
        {userType === 'FieldProvider' && (
          <>
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
              <EuiPageSideBar style={{ zIndex: 0, width: '150px' }}>
                <AdminNavigation isMobile={false} user_role={userType} />
              </EuiPageSideBar>
            </EuiShowFor>
          </>
        )}
        <EuiPageBody color="subdued">
          <EuiPageContent
            hasShadow={false}
            hasBorder={false}
            paddingSize="none"
            color="transparent"
            borderRadius="none"
          >
            <EuiPageContentBody restrictWidth={'90%'} paddingSize="s">
              {children}
            </EuiPageContentBody>
          </EuiPageContent>
        </EuiPageBody>
      </EuiPage>
    </>
  );
};

const FieldLayout = withApplicationLayout(FieldLayoutComponent);

type WithFieldLayoutProps = {
  [key: string]: any;
};

export const withFieldLayout = (component: React.FC): React.FC<WithFieldLayoutProps> => ({ children, ...props }) => (
  <FieldLayout>{React.createElement(component, props, children)}</FieldLayout>
);
