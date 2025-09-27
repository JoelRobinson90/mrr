import { Meta } from '@storybook/react';
import React, { useState } from 'react';
import { EuiBasicTableColumn, EuiButton, EuiText } from '@elastic/eui';
import { MedFlyout } from '@/common/components/MedFlyout/MedFlyout';
import { MedTable } from '@/common/components/MedTable/MedTable';
import { DataRow } from '@/admin/components/InvertedTable/InvertedTable';

export default {
  title: 'Components/MedFlyout',
  component: MedFlyout,
} as Meta;

export const EuiAuditingList = () => {
  const [showFlyout, setShowFlyout] = useState(false);
  const columns: EuiBasicTableColumn<DataRow>[] = [
    {
      field: 'name',
      name: 'Name',
    },
    {
      // field: 'value',
      name: 'Value',
      render: (item: DataRow) => <>{item.render || item.value}</>,
    },
  ];
  const prospectData: DataRow[] = [
    {
      name: 'Demand Partner',
      render: 'Hospital',
    },
    {
      name: 'Created By',
      value: 'soren@medarrive.com',
    },
    {
      name: 'Date Added',
      value: '5/17/2021',
    },
    {
      name: 'Diagnosis',
      value: 'Diabetes',
    },
    {
      name: 'Discharge Dates',
      value: '5/17/2021',
    },
    {
      name: 'Notes',
      value: 'Some notes',
    },
    {
      name: 'Preferred Language',
      value: 'Spanish',
    },
    {
      name: 'ZIP Code',
      value: '12345',
    },
  ];
  return (
    <>
      <MedFlyout
        showFooter
        cancelButton={{ text: 'Close', onClick: () => setShowFlyout(false) }}
        confirmButton={{ text: 'Save', onClick: () => setShowFlyout(false) }}
        title={'Patient ID #: 33333'}
        show={showFlyout}
        onClose={() => setShowFlyout(false)}
      >
        <EuiText>
          <MedTable tableLayout="auto" items={prospectData} columns={columns} />
        </EuiText>
      </MedFlyout>
      <EuiButton color="text" onClick={() => setShowFlyout(!showFlyout)}>
        Toggle Flyout
      </EuiButton>
    </>
  );
};
