import React, { FC, useState } from 'react';
import { OptionsProps, SelectableFilter } from '@/common/components/SelectableFilter/SelectableFilter';
import { EuiButton, EuiDatePicker, EuiDatePickerRange, EuiFieldSearch, EuiFlexGroup, EuiFlexItem } from '@elastic/eui';
import moment from 'moment';

import { getUpdatedQueryPath } from '@/common/utils/queries/queries';
import { DB_DATE_FORMAT } from '@/common/utils/dates/dates';
import { some } from 'lodash';

export type FilterOptions = {
  start_date?: boolean;
  available_tags?: OptionsProps[];
  demand_partners?: OptionsProps[];
  field_providers?: OptionsProps[];
};

export interface SearchWithFiltersProps {
  options: FilterOptions;
  filters: {
    status?: string;
    tag?: string;
    demand_partner?: string;
  };
  query: string;
  onSearch: (query: string) => void;
}

export const SearchWithFilters: FC<SearchWithFiltersProps> = ({ options, filters, query, onSearch }) => {
  const incomingStart = filters['start'] ? moment(filters['start']) : null;
  const incomingEnd = filters['end'] ? moment(filters['end']) : null;

  const page = window.location.search.includes('page=') ? { page: 1 } : '';

  const defaultFilters = {
    status: filters['status'],
    tag: filters['tag'],
    demand_partner: filters['demand_partner'],
    start: incomingStart,
    end: incomingEnd,
    field_provider: filters['field_provider'],
  };

  const shouldDisplayClearButton = some(filters, (f) => !!f);

  const [selectFilter, setSelectFilter] = useState(defaultFilters);

  const handleOnSelectFilter = (key, searchString, displayString) => {
    setSelectFilter({
      ...selectFilter,
      [key]: displayString,
    });
    window.location.assign(getUpdatedQueryPath({ [key]: searchString, ...page }));
  };

  const clearFilters = () => {
    window.location.assign(
      getUpdatedQueryPath({
        status: '',
        tag: '',
        demand_partner: '',
        start: '',
        end: '',
        field_provider: '',
        ...page,
      }),
    );
  };

  const onDateChange = (startDate: moment.Moment, endDate: moment.Moment) => {
    if (startDate && endDate) {
      window.location.assign(
        getUpdatedQueryPath({
          start: startDate.format(DB_DATE_FORMAT),
          end: endDate.format(DB_DATE_FORMAT),
          timezone: moment.tz.guess(),
          ...page,
        }),
      );
    }
  };

  const onStartChange = (date: moment.Moment) => {
    setSelectFilter({
      ...selectFilter,
      start: date,
    });
    onDateChange(date, selectFilter.end);
  };

  const onEndChange = (date: moment.Moment) => {
    setSelectFilter({
      ...selectFilter,
      end: date,
    });
    onDateChange(selectFilter.start, date);
  };

  const clearDates = () => {
    setSelectFilter({
      ...selectFilter,
      start: null,
      end: null,
    });
    window.location.assign(getUpdatedQueryPath({ start: '', end: '', ...page }));
  };

  return (
    <>
      <EuiFlexGroup wrap responsive={false} gutterSize="s" alignItems="center">
        <EuiFlexItem grow={false} style={{ maxWidth: 500, width: '100%' }}>
          <EuiFieldSearch
            placeholder="Search..."
            isClearable={true}
            defaultValue={query}
            fullWidth={true}
            onSearch={onSearch}
          />
        </EuiFlexItem>
        {options && options.start_date ? (
          <EuiFlexItem grow={false}>
            <EuiDatePickerRange
              startDateControl={
                <EuiDatePicker selected={selectFilter.start} onChange={onStartChange} placeholder="Start" />
              }
              endDateControl={
                <EuiDatePicker
                  selected={selectFilter.end}
                  onChange={onEndChange}
                  placeholder="End"
                  onClear={() => clearDates()}
                />
              }
            />
          </EuiFlexItem>
        ) : null}
      </EuiFlexGroup>
      {options && (
        <EuiFlexGroup
          alignItems="center"
          justifyContent="spaceBetween"
          wrap
          responsive={false}
          style={{ marginTop: 20, marginBottom: 20 }}
        >
          <EuiFlexItem grow={false}>
            <EuiFlexGroup data-test-id="groupFilters" gutterSize="s" alignItems="center" wrap responsive={false}>
              {options.demand_partners ? (
                <EuiFlexItem grow={false}>
                  <SelectableFilter
                    data={options.demand_partners}
                    title={'Demand Partner'}
                    handleOnSelectFilter={handleOnSelectFilter}
                    select={selectFilter.demand_partner}
                    singleSelection={false}
                  />
                </EuiFlexItem>
              ) : null}
              {options.available_tags ? (
                <EuiFlexItem grow={false}>
                  <SelectableFilter
                    data={options.available_tags}
                    title={'Tag'}
                    handleOnSelectFilter={handleOnSelectFilter}
                    select={selectFilter.tag}
                    singleSelection={false}
                  />
                </EuiFlexItem>
              ) : null}
              {options.field_providers ? (
                <EuiFlexItem grow={false}>
                  <SelectableFilter
                    data={options.field_providers}
                    title={'Field Provider'}
                    handleOnSelectFilter={handleOnSelectFilter}
                    select={selectFilter.field_provider}
                    singleSelection={true}
                  />
                </EuiFlexItem>
              ) : null}
              {shouldDisplayClearButton && (
                <EuiFlexItem grow={false}>
                  <EuiButton
                    data-test-id="clearAllFiltersSelect"
                    color="text"
                    style={{ backgroundColor: '#fed8d8', borderColor: '#be5e5e' }}
                    onClick={clearFilters}
                    iconType="crossInACircleFilled"
                  >
                    Clear All Filters
                  </EuiButton>
                </EuiFlexItem>
              )}
            </EuiFlexGroup>
          </EuiFlexItem>
        </EuiFlexGroup>
      )}
    </>
  );
};
