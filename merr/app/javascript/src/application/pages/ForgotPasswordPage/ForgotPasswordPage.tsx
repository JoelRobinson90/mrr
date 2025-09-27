import { MedTextField } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiFlexGroup,
  EuiFlexItem,
  EuiPage,
  EuiPageBody,
  EuiPageContent,
  EuiPageContentBody,
  EuiPageContentHeader,
  EuiPageContentHeaderSection,
  EuiSpacer,
  EuiTitle,
} from '@elastic/eui';
import { yupResolver } from '@hookform/resolvers';
import React from 'react';
import { useForm } from 'react-hook-form';
import * as yup from 'yup';
import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';

const forgotPasswordFormSchema = yup.object().shape({
  user: yup.object().shape({
    email: yup.string().email().required().label('Email Address'),
  }),
});

export const ForgotPasswordPage: React.FC = () => {
  const form = useForm({
    resolver: yupResolver(forgotPasswordFormSchema),
  });

  return (
    <ApplicationLayout>
      <EuiPage restrictWidth={450} style={{ zIndex: 1, position: 'relative' }}>
        <EuiPageBody component="div">
          <EuiPageContent>
            <EuiPageContentHeader>
              <EuiPageContentHeaderSection>
                <EuiTitle>
                  <h2>Reset your password</h2>
                </EuiTitle>
              </EuiPageContentHeaderSection>
            </EuiPageContentHeader>

            <EuiPageContentBody>
              <SyncForm form={form} url="/users/password" method="post">
                <MedTextField type="email" name="user.email" label="Email Address" icon="user" />

                <EuiSpacer />

                <EuiFlexGroup justifyContent="spaceBetween" responsive={false}>
                  <EuiFlexItem grow={false}>
                    <EuiButton type="submit" color="primary" fill>
                      Reset Password
                    </EuiButton>
                  </EuiFlexItem>
                  <EuiFlexItem grow={false}>
                    <EuiButtonEmpty href="/users/sign_in" color="text">
                      Cancel
                    </EuiButtonEmpty>
                  </EuiFlexItem>
                </EuiFlexGroup>
              </SyncForm>
            </EuiPageContentBody>
          </EuiPageContent>
        </EuiPageBody>
      </EuiPage>
    </ApplicationLayout>
  );
};
