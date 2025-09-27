import React from 'react';
import { EuiFlexGroup, EuiFlexItem } from '@elastic/eui';

interface FromProps {
  margin?: string;
}

const formRowStyles: React.CSSProperties = {
  borderTop: '1px solid #d3dae6',
  alignItems: 'baseline',
  padding: '0.3rem 0',
};

export const InlineFormGroup: React.FC<FromProps> = ({ children }) => {
  return (
    <EuiFlexGroup gutterSize="s" style={formRowStyles} wrap>
      {children}
    </EuiFlexGroup>
  );
};

type InlineFieldProps = {
  minWidth?: string;
  maxWidth?: string;
};

export const InlineField: React.FC<InlineFieldProps> = ({ children, minWidth, maxWidth }) => {
  return <EuiFlexItem style={{ marginRight: '0.1rem', minWidth, maxWidth }}>{children}</EuiFlexItem>;
};

export const NestedFields: React.FC = ({ children }) => {
  return (
    <EuiFlexGroup gutterSize="s" wrap>
      {children}
    </EuiFlexGroup>
  );
};

export const LeftField: React.FC<FromProps> = ({ children, margin }) => {
  return (
    <EuiFlexItem style={{ width: '15%', margin }} grow={false}>
      {children}
    </EuiFlexItem>
  );
};

export const RightField: React.FC<FromProps> = ({ children }) => {
  return <EuiFlexItem style={{ flexDirection: 'row', flexWrap: 'wrap' }}>{children}</EuiFlexItem>;
};
