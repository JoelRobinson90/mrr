import React from 'react';
import { EuiFlexItem, EuiFlexGroup, EuiBadge } from '@elastic/eui';
import { Statuses, StatusBgMap, StatusForegroundMap } from '@/common/types';
import displayStatus from '@/common/utils/statuses/displayStatus';

interface Props {
  padding?: string;
}

export const VisitStatusKey: React.FC<Props> = ({ padding = '1rem' }) => {
  return (
    <EuiFlexGroup style={{ justifyContent: 'center', padding }}>
      {Object.keys(Statuses).map((status) => {
        return (
          <EuiFlexItem grow={false} key={status}>
            <EuiBadge
              color={StatusBgMap[status]}
              style={{
                color: StatusForegroundMap[status],
                fontSize: '13px',
                fontFamily: 'Inter',
                fontWeight: 500,
                borderRadius: '4px',
                padding: '4px 8px',
              }}
            >
              {displayStatus(status)}
            </EuiBadge>
          </EuiFlexItem>
        );
      })}
    </EuiFlexGroup>
  );
};
