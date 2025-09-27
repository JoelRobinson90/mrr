import { MbscCalendarEventData, MbscResource } from '@mobiscroll/react';
import moment from 'moment';
import { Survey } from './surveyTypes';

export * from './surveyTypes';

// TODO: generate types from schema

export interface BaseModel {
  id: number;
  created_at?: string;
  updated_at?: string;
}

export type Address = {
  id?: number;
  address_line_one?: string;
  address_line_two?: string;
  city: string;
  state: string;
  county?: string;
  zipcode?: string;
  latitude?: string;
  longitude?: string;
  display_name?: string;
  timezone?: string;
  notes?: string;
};

export interface Patient extends BaseModel {
  consent_to_email?: boolean;
  preferred_contact_method?: string;
  first_name: string;
  middle_initial?: string;
  last_name: string;
  display_name?: string;
  medical_record_number: string;
  external_id?: string;
  phone_number?: string;
  phone_number_type?: string;
  date_of_birth?: string;
  gender?: string;
  address?: Address;
  demand_partner?: DemandPartner;
  user?: User;
  secondary_phone_number?: string;
  secondary_phone_number_type?: string;
  sex?: string;
  race?: string;
  ethnicity?: string;
  preferred_pronouns?: string;
  preferred_language?: string;
  emergency_contact_name?: string;
  emergency_contact_phone_number?: string;
  discharge_date?: string;
  status?: string;
  consent_to_text?: boolean;
  admin_notes?: [AdminNote];
  display_phone_number?: string;
  display_secondary_phone_number?: string;
  insurances?: Insurance[];
  needs_hra_survey?: boolean;
  pharmacies?: Pharmacy[];
  race_summary?: string;
  ethnicity_summary?: string;
  primary_care_physician?: PrimaryCarePhysician;
  tags?: Tag[];
  primary_risk_category?: string;
  custom_field_responses?: CustomFieldResponse[];
  programs?: PatientPrograms[];
  contact_email?: string;
}

export interface PatientPrograms {
  id: number;
  name: string;
}

export type CustomFieldResponse = {
  created_at?: string;
  demand_partner_custom_field: DemandPartnerCustomField;
  id?: number;
  patient_id?: number;
  value?: string;
};

export type DemandPartnerCustomField = {
  created_at?: string;
  crm_field_name?: string;
  id?: number;
  csv_column_name?: string;
  demand_partner_id?: number;
  ehr_field_name?: string;
  display_name: string;
};

export type PrimaryCarePhysician = {
  name: string;
  office_name?: string;
  office_phone_number?: string;
};

export interface User extends BaseModel {
  email?: string;
  account_type?: string;
  account?: UserAccount;
  display_name?: string;
  organization?: Organization;
}

export interface Organization {
  id: number;
  name?: string;
  display_name?: string;
}

export type WhodunnitUser = User | string;

export type UserAccount = {
  id?: number;
  first_name?: string;
  last_name?: string;
  display_name?: string;
  account_type?: string;
  field_org?: FieldOrg;
  demand_partner?: DemandPartner;
  phone_number?: string;
  phone?: string;
  field_org_id?: number;
  demand_partner_id?: number;
};

export type SmsTemplate = {
  id: number;
  message_type: string;
  message_body: string;
};

export interface DemandPartner extends BaseModel {
  name: string;
  templates?: SmsTemplate[];
}

export interface FieldOrg extends BaseModel {
  name: string;
  accounts?: UserAccount[];
}

export interface FieldProvider extends BaseModel {
  email: string;
  phone: string;
  first_name: string;
  last_name: string;
  bio: string;
  provider_level: string;
  display_name?: string;
}

export interface Tag extends BaseModel {
  name: string;
  color: string;
  group: string;
  description?: string;
  taggings_count?: number;
}

export interface Appointment extends BaseModel {
  status: string;
  start_time?: string;
  end_time?: string;
  block_start_time?: string;
  block_end_time?: string;
  field_provider?: FieldProvider;
  patient: Patient;
  demand_partner?: DemandPartner;
  address: Address;
  issue_reason?: string;
  dispatch_notes?: string;
  drive_time?: number;
  tag_list?: string[];
  admin_notes?: AdminNote[];
  covid_vaccination?: CovidVaccination;
  extra_vaccine_recipients?: ExtraVaccineRecipient[];
  confirmed_extra_vaccine_recipients?: ExtraVaccineRecipient[];
  hra_survey_status?: 'Complete' | 'Pending' | 'Not Required';
  vaccine_quantity?: number;
  tags?: Tag[];
  base_duration?: number;
  duration?: number;
  available_surveys?: Survey[];
}

export type MomentizedTimeSlot = {
  id: number;
  start_time: moment.Moment;
  end_time: moment.Moment;
};

export interface Pharmacy extends BaseModel {
  phone_number?: string;
  name: string;
  address?: Address;
}

export interface AdminNote extends BaseModel {
  content: string;
  id: number;
  created_at?: string;
  updated_at?: string;
  creator?: UserAccount;
}

export interface CovidVaccination extends BaseModel {
  reaction?: boolean;
  reaction_notes?: string;
  vaccine_type: string;
  lot?: string;
  route?: string;
  site?: string;
  dose?: string;
  expire?: string;
}

export interface Insurance extends BaseModel {
  bin_number: string;
  effective_date: string;
  name: string;
  plan_description: string;
  renewal_date: string;
  rx_group: string;
  rx_pcn: string;
  group_id: string;
  member_id: string;
}

export interface ExtraVaccineRecipient extends BaseModel {
  name: string;
  phone_number?: string;
  date_of_birth?: string;
  confirmed?: boolean;
  complete?: boolean;
  consent_to_text?: boolean;
  race?: string;
  ethnicity?: string;
  unable_to_vaccinate?: boolean;
  unable_to_vaccinate_reason?: string;
  covid_vaccination?: CovidVaccination;
  is_complete?: boolean;
}

export interface Tag {
  name: string;
  color: string;
}

export interface PatientProspect extends BaseModel {
  id: number;
  diagnosis?: Array<string>;
  discharge_end?: string;
  discharge_start?: string;
  medical_record_number?: string;
  notes?: string;
  preferred_language?: string;
  zipcode?: string;
  demand_partner?: DemandPartner;
  created_by?: WhodunnitUser;
}

export interface DiagnosisSummary {
  code: string | null;
  name: string | null;
}

export interface BackgroundJobResults {
  status: string;
  job_type: string;
  label: string;
  message: string;
  error_list: string[] | null;
}

export interface MapPoint {
  latitude: string;
  longitude: string;
}

export interface ServiceRequest {
  id: number;
  ma_id: string;
  status: string;
  status_detail: string | null;
  patient_id: number;
  program_id: number;
  service_id: number;
}

export interface StartingPoint {
  [key: string]: string[];
}

export interface SuggestedVisit {
  id: number;
  cx_end: string;
  cx_start: string;
  destination: string;
  destination_drive_time: number;
  end_time: string;
  fp_id: string;
  origin: string;
  origin_drive_time: number;
  start_time: string;
  selected?: boolean;
  fp_name: string;
  rank?: number;
  total_score?: number;
  drive_score?: number;
  proximity_score?: number;
  utilization_score?: number;
  expected_drive?: number;
  type?: string;
  run_id?: string;
  rank_category?: 'high' | 'medium' | 'low';
  arrival_window_start?: string;
  arrival_window_end?: string;
  duration?: number;
  field_provider?: FieldProvider;
  resources: VisitResource[];
}

export type Service = {
  id: string;
  name: string;
  duration: number | string;
};

export type AlayacareVisit = {
  cancel_code: {
    code: string;
  };
  visit_id?: string;
  alayacare_visit_id: string;
  local_visit_id?: string;
  fp_name?: string; // For AC support
  fp_id?: string; // For AC support
  start_date: string; // For AC support
  end_date: string; // For AC support
  start_time: string;
  end_time: string;
  cancelled: boolean;
  service_instructions?: string;
  services: Service[];
  field_provider: FieldProvider;
  canceled: boolean;
  visit_type_id: string;
  local?: boolean; // Means if visit exists in MA database
  visit_type?: VisitType;
  patient?: Patient;
  program?: Program;
  ma_visit?: {
    id: string;
    start_time: string;
    end_time: string;
    patient: Patient;
  };
  start: string;
  cx_start: string;
  cx_end: string;
  notes: any[];
  demand_partner: DemandPartner;
  status?: string;
  arrival_window_start?: string;
  arrival_window_end?: string;
  clock_in?: string;
  clock_out?: string;
  visit_group_id?: string;
  athena_telehealth_url?: string;
  confirmed: boolean;
};

export type VisitType = {
  id: number | string;
  name: string;
  alayacare_id?: string;
  services: Service[];
  duration?: number | string;
  plus_ones_enabled?: boolean;
};

export type VisitResource = {
  resource_id: string;
  start_time: string;
  end_time: string;
  in_home: boolean;
  name?: string;
  provider_role?: string;
};

export enum ScheduleEventType {
  VISIT = 'visit',
  DRIVE = 'drive',
}

export type VisitCalendarEvent = MbscCalendarEventData & {
  location?: string;
  patient?: Patient;
  visit_type?: VisitType;
  eventType?: ScheduleEventType;
  demand_partner?: DemandPartner;
  resources?: any;
};

export type DriveTimeCalendarEvent = MbscCalendarEventData & {
  eventType?: ScheduleEventType;
  demand_partner?: DemandPartner;
};

export type Program = {
  id: string;
  name: string;
  services: Service[];
  visit_types?: VisitType[];
  demand_partner?: DemandPartner;
  v2?: boolean;
  active?: boolean;
};

export enum AlayacareStatuses {
  scheduled = 'scheduled',
  cancelled = 'cancelled',
  missed = 'missed',
  completed = 'completed',
  // approved = 'approved',
  clocked = 'clocked',
  late = 'late',
  // vacant = 'vacant',
  // offered = 'offered',
  confirmed = 'confirmed',
}

export enum Statuses {
  scheduled = 'scheduled',
  confirmed = 'confirmed',
  en_route = 'en_route',
  on_site = 'on_site',
  clocked = 'clocked',
  completed = 'completed',
  late = 'late',
  missed = 'missed',
  cancelled = 'cancelled',
}

export const AlayacareStatusBgMap = {
  [AlayacareStatuses.scheduled]: '#E6F9F7',
  [AlayacareStatuses.confirmed]: '#CFFAFE',
  [AlayacareStatuses.cancelled]: '#ABB4C4',
  [AlayacareStatuses.missed]: '#ECF1D8',
  [AlayacareStatuses.completed]: '#E6F1FA',
  [AlayacareStatuses.clocked]: '#ECEBFD',
  [AlayacareStatuses.late]: '#F8E9E9',
};

export const AlayacareStatusForegroundMap = {
  [AlayacareStatuses.scheduled]: '#007E77',
  [AlayacareStatuses.confirmed]: '#0E7490',
  [AlayacareStatuses.cancelled]: '#69707D',
  [AlayacareStatuses.missed]: '#7F942A',
  [AlayacareStatuses.completed]: '#0071C2',
  [AlayacareStatuses.clocked]: '#7C609E',
  [AlayacareStatuses.late]: '#BD271E',
};

// 700 Definition for text/borders
export const StatusForegroundMap = {
  [Statuses.scheduled]: '#047857',
  [Statuses.confirmed]: '#0E7490',
  [Statuses.en_route]: '#0F766E',
  [Statuses.on_site]: '#A21CAF',
  [Statuses.clocked]: '#6D28D9',
  [Statuses.completed]: '#1D4ED8',
  [Statuses.late]: '#B91C1C',
  [Statuses.missed]: '#A16207',
  [Statuses.cancelled]: '#44403C',
};

// 100 Definition for background
export const StatusBgMap = {
  [Statuses.scheduled]: '#D1FAE5',
  [Statuses.confirmed]: '#CFFAFE',
  [Statuses.en_route]: '#CCFBF1',
  [Statuses.on_site]: '#FAE8FF',
  [Statuses.clocked]: '#EDE9FE',
  [Statuses.completed]: '#DBEAFE',
  [Statuses.late]: '#FEE2E2',
  [Statuses.missed]: '#FEF9C3',
  [Statuses.cancelled]: '#F5F5F4',
};

export type FieldProviderResource = MbscResource & { notWorking: boolean; groups: string[] };
