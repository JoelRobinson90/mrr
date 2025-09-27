import { MedTable } from '@/common/components/MedTable/MedTable';
import { EuiBasicTableColumn } from '@elastic/eui';
import React, { FC } from 'react';
import CSS from 'csstype';
export type DataRow = {
  name: string;
  value?: string | Array<string>;
  render?: React.ReactNode;
};
export interface InvertedTableProps {
  items: Array<DataRow>;
  style?: CSS.Properties;
  width?: string;
}
export const InvertedTable: FC<InvertedTableProps> = ({ items, style, width }) => {
  const columns: EuiBasicTableColumn<DataRow>[] = [
    {
      field: 'name',
      name: 'Name',
      width: width,
    },
    {
      name: 'Value',
      render: (item: DataRow) => <>{item.render || item.value}</>,
    },
  ];
  return <MedTable tableLayout="auto" items={items} columns={columns} style={style} />;
};
