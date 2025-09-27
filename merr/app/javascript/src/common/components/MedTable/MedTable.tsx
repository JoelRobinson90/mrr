import React from 'react';
import { EuiBasicTable, EuiBasicTableProps } from '@elastic/eui';

export type MedTableProps<T> = EuiBasicTableProps<T>;

export function MedTable<T>(props: MedTableProps<T>): JSX.Element {
  return <EuiBasicTable {...props} />;
}
