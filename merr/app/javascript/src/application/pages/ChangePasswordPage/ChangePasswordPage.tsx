import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';
import { MedPasswordField } from '@/common/components/forms';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import {
  EuiButton,
  EuiButtonEmpty,
  EuiCallOut,
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

const changePasswordFormSchema = yup.object().shape({
  user: yup.object().shape({
    password: yup.string().required().label('Password').min(8),
    password_confirmation: yup
      .string()
      .required()
      .label('Password Confirmation')
      .oneOf([yup.ref('password'), null], 'Passwords must match'),
    reset_password_token: yup.string(),
  }),
});

interface ChangePasswordPageProps {
  reset_password_token: string;
  errors?: string[];
}

export const ChangePasswordPage: React.FC<ChangePasswordPageProps> = ({ reset_password_token, errors }) => {
  const form = useForm({
    resolver: yupResolver(changePasswordFormSchema),
  });

  let errorCallout;
  if (errors?.length) {
    errorCallout = (
      <>
        <EuiCallOut title="Sorry, there was an error" color="danger" iconType="alert">
          <ul>
            {errors.map((msg, i) => (
              <li key={i}>{msg}</li>
            ))}
          </ul>
        </EuiCallOut>
        <EuiSpacer />
      </>
    );
  }

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
              {errorCallout}

              <SyncForm form={form} url="/users/password" method="put">
                <input
                  type="hidden"
                  name="user.reset_password_token"
                  ref={form.register}
                  value={reset_password_token}
                />
                <MedPasswordField name="user.password" label="New Password" />
                <MedPasswordField name="user.password_confirmation" label="Password Confirmation" />

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
