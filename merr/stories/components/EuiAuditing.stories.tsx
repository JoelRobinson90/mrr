import { Meta } from '@storybook/react';
import React from 'react';
import { EuiCommentList } from '@elastic/eui';
import AuditingList, { AuditEvent } from '@/common/components/AuditingList/AuditingList';

const events: Array<AuditEvent> = [
  {
    type: 'note',
    item: {
      id: 1,
      username: 'Dr. Soren Berg',
      event: 'added a note',
      message: 'Lorem Ipsum Dolorem Lorem Ipsum Dolorem Lorem Ipsum Dolorem',
      timestamp: '2021-03-16T16:35:23.702Z',
    },
  },
  {
    type: 'event',
    item: {
      id: 2,
      username: 'Dr. Soren Berg',
      event: "updated patient's email",
      timestamp: '2021-03-16T16:35:23.702Z',
    },
  },
  {
    type: 'note',
    item: {
      id: 3,
      username: 'Dr. Soren Berg',
      event: 'added a note',
      message: 'Lorem Ipsum Dolorem Lorem Ipsum Dolorem Lorem Ipsum Dolorem',
      timestamp: '2021-03-16T16:35:23.702Z',
    },
  },
  {
    type: 'event',
    item: {
      id: 4,
      username: 'Dr. Soren Berg',
      event: "updated patient's email",
      timestamp: '2021-03-16T16:35:23.702Z',
    },
  },
  {
    type: 'event',
    item: {
      id: 5,
      username: 'Dr. Soren Berg',
      event: "updated patient's email",
      timestamp: '2021-03-16T16:35:23.702Z',
    },
  },
];

export default {
  title: 'Components/EuiAuditing',
  component: EuiCommentList,
  argTypes: { onClickCopy: { action: 'clicked' } },
} as Meta;

export const EuiAuditingList = () => {
  return (
    <AuditingList
      patient={{ id: 1, medical_record_number: '123', first_name: 'test', last_name: 'test' }}
      events={events}
    />
  );
};
