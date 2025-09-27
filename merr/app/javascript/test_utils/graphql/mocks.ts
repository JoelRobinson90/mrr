import faker from 'faker';
import { MockedResponse } from '@apollo/client/testing';
import { GetCurrentUserDocument, GetCurrentUserQuery, GetVisitRequestsDocument } from '@/generated/graphql';
import { randomNumericId } from './factories';

export const currentUserAdminMock: MockedResponse<GetCurrentUserQuery> = {
  request: {
    query: GetVisitRequestsDocument,
  },
  result: {
    data: {
      getCurrentUser: {
        id: randomNumericId(),
        email: faker.internet.email(),
        displayName: `${faker.name.firstName()} ${faker.name.lastName()}`,
        account: {
          __typename: 'MedarriveAdmin',
        },
      },
    },
  },
};
