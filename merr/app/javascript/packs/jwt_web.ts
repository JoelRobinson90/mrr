import WebpackerReact from 'webpacker-react';

import '@/common/styles';

import { SchedulerIframePage } from '@/jwt_web/SchedulerIframePage/SchedulerIframePage';

WebpackerReact.setup({
  SchedulerIframePage,
});
