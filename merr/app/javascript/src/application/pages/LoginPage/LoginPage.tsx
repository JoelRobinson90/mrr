import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';

import {
  EuiButton,
  EuiFlexGroup,
  EuiFlexItem,
  EuiPage,
  EuiPageBody,
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageContentHeaderSection,
  EuiTitle,
  EuiImage,
  EuiText,
  EuiSpacer,
} from '@elastic/eui';
import React from 'react';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';
import homeImg from '@/../images/svg/home-image.svg';
import medarriveText from '@/../images/svg/medarrive-with-text.svg';
import logo from '@/../images/svg/logos/logo.svg';
import styled from 'styled-components';

const ImageFlexItem = styled(EuiFlexItem)<{ bgImg: string }>`
  display: none;
  @media (min-width: 768px) {
    display: flex;
    align-items: center;
    justify-content: center;
    background-image: ${({ bgImg }) => `url(${bgImg})`};
    background-repeat: no-repeat;
    background-position: center center;
    background-size: cover;
    background-color: #43c7e2;
    img {
      max-width: max-content;
      width: 90%;
      height: auto;
    }
  }
`;

const ImageHome = styled(EuiImage)`
  width: 96px;
  @media (min-width: 768px) {
    width: auto;
  }
`;

const PageContentBody = styled(EuiPageContentBody)`
  width: 100%;
  max-width: 386px;
  height: calc(100vh - 120px);
  margin-left: auto;
  margin-right: auto;
  margin-top: 45px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  @media (min-width: 768px) {
    margin-top: 161px;
    justify-content: unset;
    height: auto;
  }
`;

export const LoginPage: React.FC = () => {
  const OktaLogIn = () => submitSyncForm('/users/auth/oktaoauth', 'post');

  return (
    <ApplicationLayout background={false}>
      <EuiFlexGroup gutterSize="none" style={{ height: '100vh' }}>
        <EuiFlexItem style={{ marginBottom: '0 !important', width: '50%' }}>
          <EuiPage paddingSize="none">
            <EuiPageBody component="div">
              <EuiPageContent>
                <EuiPageContentHeader>
                  <EuiPageContentHeaderSection>
                    <ImageHome alt="home image" src={logo} />
                  </EuiPageContentHeaderSection>
                </EuiPageContentHeader>
                <PageContentBody>
                  <div>
                    <EuiTitle size="m">
                      <h1 style={{ fontWeight: 700, textAlign: 'center' }}>Welcome Back!</h1>
                    </EuiTitle>
                    <EuiSpacer size="l" />
                    <EuiText style={{ fontWeight: 400, color: '#69707D' }}>
                      Welcome to <span style={{ fontWeight: 600 }}>MedArrive</span>, please sign in to enter our admin
                      system.
                    </EuiText>
                    <EuiSpacer size="xxl" />
                  </div>
                  <EuiButton
                    style={{ backgroundColor: '#0077CC', borderColor: '#0077CC' }}
                    fill
                    fullWidth
                    onClick={OktaLogIn}
                  >
                    Sign In
                  </EuiButton>
                </PageContentBody>
              </EuiPageContent>
            </EuiPageBody>
          </EuiPage>
        </EuiFlexItem>
        <ImageFlexItem bgImg={homeImg}>
          <img src={medarriveText} alt="medarrive" />
        </ImageFlexItem>
      </EuiFlexGroup>
    </ApplicationLayout>
  );
};
