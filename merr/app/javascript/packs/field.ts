import WebpackerReact from 'webpacker-react';

import { DebugPage } from '@/admin/pages/debug/DebugPage';
import { FieldSchedulerPatientIndexPage } from '@/admin/pages/patients/PatientIndexPage';
import { FieldSchedulerPatientShowPage } from '@/admin/pages/patients/PatientShowPage';
import { FieldScheduleVisitPage } from '@/admin/pages/scheduling/ScheduleVisitPage';
import { PatientCancelVisitCalendarTabPartial } from '@/admin/pages/patients/PatientCancelVisitCalendarTabPartial';
import { registerPartials } from '@/common/components/RemotePartial/RemotePartial';
import { EditVisitPartial } from '@/admin/pages/patients/visits/EditVisitPartial';
import { CapacityPage } from '@/admin/pages/capacity/CapacityPage/CapacityPage';

import '@/common/styles';

WebpackerReact.setup({
  DebugPage,
  FieldSchedulerPatientIndexPage,
  FieldSchedulerPatientShowPage,
  FieldScheduleVisitPage,
  CapacityPage
});

registerPartials({
  PatientCancelVisitCalendarTabPartial,
  EditVisitPartial,
});
