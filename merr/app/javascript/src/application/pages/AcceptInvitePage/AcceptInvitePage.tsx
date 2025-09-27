import { ApplicationLayout } from '@/application/components/ApplicationLayout/ApplicationLayout';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';
import {
  EuiPage,
  EuiPageBody,
  EuiText,
  EuiPageContent,
  EuiPageContentHeader,
  EuiPageContentHeaderSection,
  EuiPageContentBody,
  EuiTitle,
  EuiSpacer,
  EuiButton,
} from '@elastic/eui';
import * as yup from 'yup';
import React from 'react';
import { MedPasswordField, MedTextField } from '@/common/components/forms';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers';
import { User } from '@/common/types';
import styled from 'styled-components';
import zxcvbn from 'zxcvbn';

yup.addMethod(yup.string, 'passwordEstimator', function () {
  return this.test({
    message: 'Password not good enough',
    test: function (pw) {
      const result = zxcvbn(pw);
      if (result.score < 2) {
        return this.createError({
          message: result.feedback.warning,
        });
      }
      return true;
    },
  });
});

const acceptInviteFormSchema = yup.object({
  user: yup.object({
    account_attributes: yup.object({
      first_name: yup.string().required().label('First name'),
      last_name: yup.string().required().label('Last name'),
    }),
    // @ts-ignore
    password: yup.string().required().label('Password').min(8).passwordEstimator(),
    password_confirmation: yup
      .string()
      .required()
      .label('Password Confirmation')
      .oneOf([yup.ref('password'), null], 'Passwords must match'),
    reset_password_token: yup.string().required(),
  }),
});

type FormValues = yup.TypeOf<typeof acceptInviteFormSchema>;

type Props = {
  user: User;
  token: string;
};

const MedSimplePageContent = styled(EuiPageContent)`
  && {
    min-width: 320px;
    max-width: 500px;
  }
`;

export const AcceptInvitePage: React.FC<Props> = ({ user, token }) => {
  const { account } = user;
  const { first_name, last_name, field_org } = account;

  const defaultValues: FormValues = {
    user: {
      reset_password_token: token,
      account_attributes: {
        first_name: first_name || '',
        last_name: last_name || '',
      },
      password: '',
      password_confirmation: '',
    },
  };

  const form = useForm<FormValues>({
    defaultValues,
    resolver: yupResolver(acceptInviteFormSchema),
  });

  return (
    <ApplicationLayout>
      <EuiPage style={{ zIndex: 1, position: 'relative' }}>
        <EuiPageBody component="div">
          <MedSimplePageContent verticalPosition="center" horizontalPosition="center">
            <EuiPageContentHeader>
              <EuiPageContentHeaderSection>
                <EuiTitle>
                  <h2>Accept your invite</h2>
                </EuiTitle>
              </EuiPageContentHeaderSection>
            </EuiPageContentHeader>

            <EuiPageContentBody>
              {field_org ? (
                <>
                  <EuiText>
                    <p>
                      Fill out the form to complete registration with <strong>{field_org.name}</strong>.
                    </p>
                  </EuiText>
                  <EuiSpacer />
                </>
              ) : null}
              <SyncForm form={form} url="/users/invites" method="put">
                <input type="hidden" ref={form.register} name="user.reset_password_token" />
                <MedTextField name="user.account_attributes.first_name" label="First Name" fullWidth />
                <MedTextField name="user.account_attributes.last_name" label="Last Name" fullWidth />
                <MedPasswordField name="user.password" label="Password" fullWidth />
                <MedPasswordField name="user.password_confirmation" label="Password Confirmation" fullWidth />

                <EuiSpacer />

                <EuiButton type="submit" color="primary" fill>
                  Accept Invite
                </EuiButton>
              </SyncForm>
            </EuiPageContentBody>
          </MedSimplePageContent>
        </EuiPageBody>
      </EuiPage>
    </ApplicationLayout>
  );
};
