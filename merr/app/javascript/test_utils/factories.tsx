import faker from 'faker';
import { Address, AdminNote, Appointment, DemandPartner, Patient, User, Survey } from '@/common/types';

export const randomId = () => Math.floor(Math.random() * 100_000);

const commonModelAttributes = () => ({
  id: randomId(),
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
});

export const buildPatient = (fields: Partial<Patient> = {}): Patient => {
  const first_name = fields.first_name || faker.name.firstName();
  const last_name = fields.last_name || faker.name.lastName();
  return {
    ...commonModelAttributes(),
    first_name,
    last_name,
    display_name: `${first_name} ${last_name}`,
    medical_record_number: faker.random.alphaNumeric(),
    ...fields,
  };
};

export const buildAddress = (fields: Partial<Address> = {}): Address => ({
  address_line_one: faker.address.streetAddress(),
  city: faker.address.city(),
  county: faker.address.city(),
  state: faker.address.stateAbbr(),
  latitude: faker.address.latitude(),
  longitude: faker.address.longitude(),
  display_name: faker.address.stateAbbr(),
  timezone: 'America/Los_Angeles',
  ...fields,
});

export const buildAppointment = (fields: Partial<Appointment> = {}): Appointment => ({
  ...commonModelAttributes(),
  status: 'Assigned',
  patient: buildPatient(),
  address: buildAddress(),
  tag_list: [],
  admin_notes: [],
  available_surveys: [],
  ...fields,
});

export const buildDemandPartner = (fields: Partial<DemandPartner> = {}): DemandPartner => ({
  ...commonModelAttributes(),
  name: faker.company.companyName(),
  ...fields,
});

export const buildUser = (fields: Partial<User> = {}): User => ({
  ...commonModelAttributes(),
  display_name: `${faker.name.firstName()} ${faker.name.lastName()}`,
  ...fields,
});

export const buildAdminNote = (fields: Partial<AdminNote> = {}): AdminNote => ({
  ...commonModelAttributes(),
  content: faker.random.words(),
  creator: buildUser(),
  ...fields,
});

export const buildSurvey = (fields: Partial<Survey> = {}): Survey => ({
  ...commonModelAttributes(),
  name: 'clover_care_visit',
  responded: false,
  responded_at: null,
  meta: {
    title: 'Clover Care Visit Program',
  },
  ...fields,
});
