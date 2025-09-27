import WebpackerReact from 'webpacker-react';

import '@/common/styles';

import { DebugPage } from '@/admin/pages/debug/DebugPage';

import { PatientIndexPage } from '@/admin/pages/patients/PatientIndexPage';
import { PatientShowPage } from '@/admin/pages/patients/PatientShowPage';
import { PatientCreatePage } from '@/admin/pages/patients/PatientCreatePage';
import { PatientHistoryPage } from '@/admin/pages/patients/PatientHistoryPage';
import { TagIndexPage } from '@/admin/pages/tags/TagIndexPage';
import { TagShowPage } from '@/admin/pages/tags/TagShowPage';
import { TagEditPage } from '@/admin/pages/tags/TagEditPage';
import { FieldOrgIndexPage } from '@/admin/pages/field_orgs/FieldOrgIndexPage';
import { FieldOrgShowPage } from '@/admin/pages/field_orgs/FieldOrgShowPage';
import { DemandPartnerIndexPage } from '@/admin/pages/demand_partners/DemandPartnerIndexPage';
import { DemandPartnerShowPage } from '@/admin/pages/demand_partners/DemandPartnerShowPage';
import { AppointmentIndexPage } from '@/admin/pages/appointments/AppointmentIndexPage';
import { AppointmentShowPage } from '@/admin/pages/appointments/AppointmentShowPage/AppointmentShowPage';
import { AppointmentEditPage } from '@/admin/pages/appointments/AppointmentEditPage';

import { PatientProspectIndexPage } from '@/admin/pages/patient_prospects/PatientProspectIndexPage/PatientProspectIndexPage';

import { AppointmentEditPartial } from '@/admin/pages/appointments/AppointmentEditPartial';
import { registerPartials } from '@/common/components/RemotePartial/RemotePartial';

import AdminNavigation from '@/admin/components/AdminLayout/components/AdminNavigation';

import { KustomerMapSelectionNewPage } from '@/admin/pages/kustomer/patients/KustomerMapSelectionNewPage';

import { BackgroundJobResultsIndexPage } from '@/admin/pages/super_admin/BackgroundJobResultsIndexPage';

import { AlayacareCreateVisit } from '@/admin/pages/alayacare/AlayacareCreateVisit';
import { FieldProviderSchedulesPage } from '@/admin/pages/alayacare/FieldProviderSchedulesPage';

import { PatientVisitsCalendarTab } from '@/admin/pages/patients/PatientVisitsCalendarTab';
import { PatientCancelVisitCalendarTabPartial } from '@/admin/pages/patients/PatientCancelVisitCalendarTabPartial';
import { DataImporterPage } from '@/admin/pages/super_admin/DataImporterPage';
import { EditVisitPartial } from '@/admin/pages/patients/visits/EditVisitPartial';

import { CapacityPage } from '@/admin/pages/capacity/CapacityPage/CapacityPage';

import { OutreachCampaignsIndexPage } from '@/admin/pages/outreach_campaigns/OutreachCampaignsIndexPage';
import { ScheduleVisitPage } from '@/admin/pages/scheduling/ScheduleVisitPage';

WebpackerReact.setup({
  DataImporterPage,
  DebugPage,
  PatientIndexPage,
  PatientShowPage,
  PatientCreatePage,
  PatientHistoryPage,
  TagIndexPage,
  TagShowPage,
  TagEditPage,
  FieldOrgIndexPage,
  FieldOrgShowPage,
  DemandPartnerIndexPage,
  DemandPartnerShowPage,
  CapacityPage,
  AppointmentIndexPage,
  AppointmentShowPage,
  AppointmentEditPage,

  PatientProspectIndexPage,

  AppointmentEditPartial,

  KustomerMapSelectionNewPage,

  BackgroundJobResultsIndexPage,

  AlayacareCreateVisit,
  FieldProviderSchedulesPage,

  OutreachCampaignsIndexPage,

  ScheduleVisitPage,
});

registerPartials({
  AppointmentEditPartial,
  AdminNavigation,
  PatientVisitsCalendarTab,
  PatientCancelVisitCalendarTabPartial,
  EditVisitPartial,
});
