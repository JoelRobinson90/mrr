import { MedTable } from '@/common/components/MedTable/MedTable';
import { Patient } from '@/common/types';
import {
  EuiBasicTableColumn,
  EuiCopy,
  EuiFlexGroup,
  EuiFlexItem,
  EuiIcon,
  EuiInMemoryTable,
  EuiText,
  EuiTextColor,
} from '@elastic/eui';
import React from 'react';
import { Result } from './DataImporterPage';

const StatusIcon: React.FC<{ status: string }> = ({ status }) => {
  const color = status == 'Scheduled with Issue' ? 'danger' : 'success';
  const iconType = color === 'success' ? 'check' : 'alert';

  return (
    <EuiFlexItem grow={false}>
      <EuiIcon type={iconType} size="m" color={color} />
    </EuiFlexItem>
  );
};

type CompoundFieldProps = {
  name: string;
  status: string;
  subtitle: string;
};

const CompoundField: React.FC<CompoundFieldProps> = ({ name, status, subtitle }) => {
  return (
    <div>
      <EuiFlexGroup gutterSize="s" alignItems="center" responsive={false}>
        {!!status ? <StatusIcon status={status} /> : null}
        <EuiFlexItem grow={false}>
          <EuiText size="m">
            <p>{name}</p>
          </EuiText>
          <EuiText size="xs">
            <EuiCopy textToCopy={subtitle}>
              {(copy) => (
                <EuiTextColor
                  color="subdued"
                  onClick={(e) => {
                    copy();
                    e.stopPropagation();
                  }}
                >
                  <p style={{ color: '#98A2B3' }}>{subtitle}</p>
                </EuiTextColor>
              )}
            </EuiCopy>
          </EuiText>
        </EuiFlexItem>
      </EuiFlexGroup>
    </div>
  );
};

const columns: Array<EuiBasicTableColumn<Result>> = [
  {
    field: 'id',
    name: 'ID',
  },
  {
    field: 'job_type',
    name: 'Import to',
  },
  {
    field: 'label',
    name: 'File Name',
  },
  {
    field: 'message',
    name: 'Message',
  },
  {
    field: 'status',
    name: 'Status',
  },
  {
    field: 'error_list',
    name: 'Errors',
  },
  {
    field: 'created_at',
    name: 'date',
  },
];

interface PatientsTableProps {
  onClick?: (patient: Patient) => void;
  import_results?: Result[];
}

const getRowProps = (onClick?: (patient: Patient) => void) => (item: Patient) => ({
  onClick: onClick ? () => onClick(item) : null,
});

export const ImportTable: React.FC<PatientsTableProps> = ({ import_results, onClick }) => {
  const truncatedErrorList = import_results.map((result) => {
    result.error_list = result.error_list?.slice(0, 25);
    return result;
  });
  return <MedTable items={truncatedErrorList} columns={columns} rowProps={getRowProps(onClick)} />;
};

export const InMemoryPatientsTable: React.FC<PatientsTableProps> = ({ import_results, onClick }) => {
  const truncatedErrorList = import_results.map((result) => {
    result.error_list = result.error_list?.slice(0, 25);
    return result;
  });

  return (
    <EuiInMemoryTable
      itemId="id"
      items={truncatedErrorList}
      columns={columns}
      rowProps={getRowProps(onClick)}
      pagination
      search
    />
  );
};
