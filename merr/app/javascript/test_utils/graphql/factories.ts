import { formatUtc } from '@/common/utils/dates/dates';
import { AlayacareVisit } from '@/generated/graphql';
import faker from 'faker';
import moment from 'moment';

export const randomNumericId = () => Math.floor(Math.random() * 100_000).toString();

export const buildAlayacareVisit = (fields: Partial<AlayacareVisit> = {}): AlayacareVisit => {
  const { patient, ...visitFields } = fields;
  const { address, externalId, ...patientFields } = patient || {};
  const firstName = faker.name.firstName();
  const lastName = faker.name.lastName();
  return {
    alayacareVisitId: randomNumericId(),
    demandPartnerId: randomNumericId(),
    startTime: formatUtc(moment().set('h', 16).set('m', 0).set('s', 0)),
    endTime: formatUtc(moment().set('h', 17).set('m', 30).set('s', 0)),
    location: faker.address.nearbyGPSCoordinate().join(','),
    status: 'Scheduled',
    clientId: randomNumericId(),
    patient: {
      firstName,
      lastName,
      displayName: [firstName, lastName].join(' '),
      id: randomNumericId(),
      maId: randomNumericId(),
      externalId,
      consentToText: false,
      address: {
        addressLineOne: faker.address.streetAddress(),
        addressLineTwo: faker.address.secondaryAddress(),
        city: faker.address.city(),
        state: faker.address.stateAbbr(),
        zipcode: faker.address.zipCode(),
        ...(address || {}),
      },
      serviceRequests: [],
      ...(patientFields || {}),
    },
    ...(visitFields || {}),
  };
};
