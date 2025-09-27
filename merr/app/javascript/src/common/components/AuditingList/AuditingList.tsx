import { Patient } from '@/common/types';
import { formatDate, LONG_DATE_FORMAT, TIME_FORMAT_WITH_ZONE } from '@/common/utils/dates/dates';
import { EuiCommentProps, EuiAvatar, EuiCommentList, EuiFlexGroup, EuiFlexItem } from '@elastic/eui';
import React, { ReactNode, useMemo } from 'react';

export type AuditEvent = {
  type: 'note' | 'event';
  item: {
    id: number;
    username: string;
    message?: string;
    event: ReactNode;
    timestamp: string;
  };
};

export type AuditingListProps = {
  events: Array<AuditEvent>;
  patient?: Patient;
  color?: string;
};

type EventAvatarProps = {
  username: string;
  color?: string;
};

const EventAvatar: React.FC<EventAvatarProps> = ({ username, color }) => {
  return (
    <EuiFlexGroup responsive={false} alignItems="center" gutterSize="s">
      <EuiFlexItem grow={false}>
        <EuiAvatar size="s" type="space" name={username} color={color} />
      </EuiFlexItem>
      <EuiFlexItem grow={false}>{username}</EuiFlexItem>
    </EuiFlexGroup>
  );
};

const AuditingList: React.FC<AuditingListProps> = ({ patient, events, color = '#000000' }) => {
  const timezone = patient?.address?.timezone;
  const comments = useMemo(
    () =>
      events.map((e) => {
        const event: EuiCommentProps = {
          event: e.item.event,
          timestamp: `on ${formatDate(e.item.timestamp, `${LONG_DATE_FORMAT} ${TIME_FORMAT_WITH_ZONE}`, timezone)}`,
          username: '',
        };
        if (e.type === 'event') {
          event.type = 'update';
          event.username = <EventAvatar username={e.item.username} color={color} />;
          event.children = (
            <ul>
              {e.item.message?.split('\n').map((message, key) => (
                <li key={key}>{message}</li>
              ))}
            </ul>
          );
        } else if (e.type === 'note') {
          event.username = e.item.username;
          event.children = (
            <ul>
              <li>{e.item.message}</li>
            </ul>
          );
          event.timelineIcon = <EuiAvatar size="l" name={e.item.username} color={color} />;
        }
        return event;
      }),
    [events.length],
  );

  return <EuiCommentList data-test-id="paperTrails" comments={comments} />;
};

export default AuditingList;
