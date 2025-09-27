import { EuiBadge } from '@elastic/eui';
import React from 'react';

export type MedBadgeProps = {
  text: string;
  color?: string;
};

// THIS IS ESSENTIALLY DEPRECATED -- REAL VALUES ARE IN AlayacareStatusBgMap, AlayacareStatuses, AlayacareStatusForegroundMap in types
export const STATUS_COLOR_MAP = {
  // Shared statuses
  Created: '#ccc',
  Archived: '#888',

  // Appointment statuses
  'Pending Acceptance': '#F04E98',
  'Awaiting Scheduling': '#4587f4',
  Alayacare: '#F04E98',
  Vacant: '#eaa93b',
  Assigned: '#5eb091',
  'En Route': '#5eb091',
  'On Site': '#5eb091',
  'In Progress': '#B91C1C',
  Complete: '#9aa2b2',
  Issue: '#cb3072',
  Canceled: '#000000',
  Pending: '#9aa2b2',

  // Patient statuses
  'Referred: Needs Scheduling': '#db1374',
  'Referred: Scheduled': '#00b3a4',
  'Care Complete': '#98a2b3',
  'Scheduled with Issue': '#dd0a73',
  'Referred: Cancelled': '#9aa2b2',
};

export const MedBadge: React.FC<MedBadgeProps> = ({ text, color }) => {
  const status_color = color || STATUS_COLOR_MAP[text];

  return <EuiBadge color={status_color}> {text}</EuiBadge>;
};
