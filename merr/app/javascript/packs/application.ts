import WebpackerReact from 'webpacker-react';

import '@/common/styles';

import { LoginPage } from '@/application/pages/LoginPage/LoginPage';
import { ForgotPasswordPage } from '@/application/pages/ForgotPasswordPage/ForgotPasswordPage';
import { ChangePasswordPage } from '@/application/pages/ChangePasswordPage/ChangePasswordPage';
import { AcceptInvitePage } from '@/application/pages/AcceptInvitePage/AcceptInvitePage';

WebpackerReact.setup({
  LoginPage,
  ForgotPasswordPage,
  ChangePasswordPage,
  AcceptInvitePage,

  HealthCheckPage: () => 'OK',
});
