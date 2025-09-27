import React from 'react';
import { EuiSearchBar, SearchFilterConfig } from '@elastic/eui';

export interface PatientDataRow {
  name: string;
  value?: any;
  render?: any;
}
export interface PatientSearchBarProps {
  items: Array<PatientDataRow>;
  onFilter: (Array) => void;
}

export const PatientSearchBar: React.FC<PatientSearchBarProps> = ({ items, onFilter }) => {
  const initialQuery = EuiSearchBar.Query.MATCH_ALL;

  const onChange = ({ query, error }) => {
    if (error) {
    } else {
      const queriedItems = EuiSearchBar.Query.execute(query, items);
      onFilter(queriedItems);
    }
  };
  const filters: SearchFilterConfig[] = [];

  return (
    <EuiSearchBar
      filters={filters}
      box={{ placeholder: 'Search...' }}
      onChange={onChange}
      defaultQuery={initialQuery}
    />
  );
};
