import React from 'react';
import { EuiBadge, EuiIcon } from '@elastic/eui';

const GREEN_STATUSES = ['scheduled', 'completed'];

type Status = string;

interface Props {
  status: Status;
}

const isSuccess = (status: Status) => GREEN_STATUSES.includes(status.toLowerCase());

export const MedArriveBadge: React.FC<Props> = ({ status }) => {
  const color = isSuccess(status) ? 'hollow' : '#DD0A73';
  return <EuiBadge color={color}>{status}</EuiBadge>;
};

export const MedArriveStatusIcon: React.FC<Props> = ({ status }) => {
  const color = isSuccess(status) ? 'success' : 'danger';
  const iconType = color === 'success' ? 'check' : 'alert';
  return <EuiIcon type={iconType} size="m" color={color} />;
};
