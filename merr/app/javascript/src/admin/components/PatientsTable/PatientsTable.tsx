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
import { formatDate, SHORT_DATE_FORMAT, TIME_FORMAT } from '@/common/utils/dates/dates';

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

const columns: Array<EuiBasicTableColumn<Patient>> = [
  {
    field: 'created_at',
    name: 'Date Received',
    render: (created_at: Date) => {
      return `${formatDate(created_at, SHORT_DATE_FORMAT)} ${formatDate(created_at, TIME_FORMAT)}`;
    },
  },
  {
    field: 'first_name',
    name: 'Name',
    render: (_, { first_name, middle_initial, last_name, status, medical_record_number }) => {
      // the first param is always the field name (but we need the entire patient object to get access to MRN & status as well)
      return (
        <CompoundField
          name={`${first_name} ${middle_initial ? middle_initial : ''} ${last_name}`}
          status={status}
          subtitle={`Patient ID: #${medical_record_number}`}
        />
      );
    },
  },
  {
    field: 'display_phone_number',
    name: 'Phone Number',
  },
  {
    field: 'address',
    name: 'City / State',
    render: (address) => {
      const location = !!address ? `${address.city}, ${address.state}` : 'None';
      return location;
    },
  },
];

const fullAddressColumn: Array<EuiBasicTableColumn<Patient>> = [...columns];

fullAddressColumn.splice(3, 0, {
  field: 'address',
  name: 'Street Address',
  render: (address) => {
    const location = !!address ? `${address.address_line_one}` : 'None';
    return location;
  },
});

interface PatientsTableProps {
  data: Patient[];
  fullAddress?: boolean;
  onClick?: (patient: Patient) => void;
  useExternalAcctLayout?: boolean;
}

const getRowProps = (onClick?: (patient: Patient) => void) => (item: Patient) => ({
  onClick: onClick ? () => onClick(item) : null,
});

export const PatientsTable: React.FC<PatientsTableProps> = ({
  data,
  fullAddress = false,
  onClick,
  useExternalAcctLayout,
}) => {
  if (!useExternalAcctLayout) {
    columns.splice(4, 0, {
      field: 'demand_partner.name',
      name: 'Partner',
    });
  }

  return <MedTable items={data} columns={fullAddress ? fullAddressColumn : columns} rowProps={getRowProps(onClick)} />;
};

export const InMemoryPatientsTable: React.FC<PatientsTableProps> = ({ data, fullAddress = false, onClick }) => {
  return (
    <EuiInMemoryTable
      itemId="id"
      items={data}
      columns={fullAddress ? fullAddressColumn : columns}
      rowProps={getRowProps(onClick)}
      pagination
      search
    />
  );
};
