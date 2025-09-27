import React from 'react';
import { EuiFlexGroup, EuiFlexItem, EuiSpacer, EuiText, EuiPanel } from '@elastic/eui';

interface SidePanelProps {
  children: React.ReactNode;
  error?: string;
  justifyContent?: any;
  isFieldLayout?: boolean;
}

export const SidePanel: React.FC<SidePanelProps> = ({ children, error, justifyContent, isFieldLayout }) => {
  return (
    <EuiFlexItem
      grow={false}
      style={{ margin: isFieldLayout ? '12px 0 0 0' : 0, width: 320, backgroundColor: '#FAFBFD', maxHeight: '751px' }}
    >
      <EuiPanel style={{ padding: 24, width: 320, height: '100%' }}>
        <EuiFlexGroup
          gutterSize="none"
          style={{ height: '100%', position: 'relative' }}
          direction="column"
          justifyContent={justifyContent}
        >
          {error ? (
            <EuiFlexItem>
              <EuiText color="danger">{error}</EuiText>
              <EuiSpacer size="m" />
            </EuiFlexItem>
          ) : (
            children
          )}
        </EuiFlexGroup>
      </EuiPanel>
    </EuiFlexItem>
  );
};
