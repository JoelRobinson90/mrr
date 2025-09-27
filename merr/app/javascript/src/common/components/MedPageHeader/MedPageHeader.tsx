import React, { useState } from 'react';
import {
  EuiHeader,
  EuiHeaderLogo,
  EuiHeaderSectionItem,
  EuiHeaderSectionItemButton,
  EuiIcon,
  EuiBreadcrumb,
  htmlIdGenerator,
  EuiAvatar,
  EuiPopover,
  EuiFlexGroup,
  EuiFlexItem,
  EuiText,
  EuiSpacer,
  EuiLink,
  EuiImage,
  EuiBadge,
} from '@elastic/eui';
import logoImg from '@/../images/logos/mark-color.png';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';

const renderLogo = (
  <EuiHeaderSectionItem border="right">
    <EuiHeaderLogo
      href="/"
      aria-label="Go to home page"
      iconType={() => <EuiImage url={logoImg} alt="MedArrive Logo" size={24} style={{ width: 24, height: 24 }} />}
    />
  </EuiHeaderSectionItem>
);

const HeaderUserMenu: React.FC<{ userName: string | undefined }> = ({ userName }) => {
  const id = htmlIdGenerator()();
  const [isOpen, setIsOpen] = useState(false);

  const onMenuButtonClick = () => setIsOpen(!isOpen);
  const closeMenu = () => setIsOpen(false);

  const button = (
    <EuiHeaderSectionItemButton name="hamburger" onClick={onMenuButtonClick}>
      <EuiIcon type="apps" size="m" />
    </EuiHeaderSectionItemButton>
  );

  const logOut = () => submitSyncForm('/users/sign_out', 'delete');

  return (
    <EuiPopover
      id={id}
      repositionOnScroll
      button={button}
      isOpen={isOpen}
      anchorPosition="downRight"
      closePopover={closeMenu}
      panelPaddingSize="none"
    >
      <div style={{ width: 320 }}>
        <EuiFlexGroup gutterSize="m" className="euiHeaderProfile" responsive={false}>
          {userName && (
            <EuiFlexItem grow={false}>
              <EuiAvatar name={userName} size="xl" />
            </EuiFlexItem>
          )}

          <EuiFlexItem>
            <EuiText>
              <p>{userName}</p>
            </EuiText>

            <EuiSpacer size="m" />

            <EuiFlexGroup>
              <EuiFlexItem>
                <EuiFlexGroup justifyContent="spaceBetween">
                  <EuiFlexItem grow={false}>{/* <EuiLink>Edit profile</EuiLink> */}</EuiFlexItem>

                  <EuiFlexItem grow={false}>
                    <EuiLink name="signOut" onClick={logOut}>
                      Sign out
                    </EuiLink>
                  </EuiFlexItem>
                </EuiFlexGroup>
              </EuiFlexItem>
            </EuiFlexGroup>
          </EuiFlexItem>
        </EuiFlexGroup>
      </div>
    </EuiPopover>
  );
};

export type MedPageHeaderProps = {
  breadcrumbs?: EuiBreadcrumb[];
  userName: string | undefined;
  openMenu?: boolean;
  environment?: string;
  isFieldSite?: boolean;
};

export const MedPageHeader: React.FC<MedPageHeaderProps> = ({ breadcrumbs = [], userName, openMenu, environment, isFieldSite }) => {
  const inProd = environment?.toLowerCase().includes('prod')

  const envLabel = (
    <EuiBadge color={inProd ? 'danger' : 'success'} style={{ color: 'white' }}>
      {environment}
    </EuiBadge>
  );
  const sections = [
    {
      breadcrumbs,
      items: [renderLogo],
      breadcrumbProps: {
        'aria-label': 'Header sections breadcrumbs',
      },
    },
    {
      items: !inProd && isFieldSite ? [<HeaderUserMenu key="usermenu" userName={userName} />] : [envLabel, <HeaderUserMenu key="usermenu" userName={userName} />],
    },
  ];

  return <EuiHeader position={openMenu ? 'fixed' : 'static'} sections={sections} style={{ fontFamily: 'Raleway' }} />;
};
