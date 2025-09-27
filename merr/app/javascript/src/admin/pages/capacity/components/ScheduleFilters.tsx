import React, { useCallback, useEffect, useState } from 'react';
import {
  EuiFlexGrid,
  EuiFlexItem,
  EuiFormRow,
  EuiComboBox,
  EuiCheckbox,
  EuiSpacer,
  EuiButtonEmpty,
  EuiFlexGroup,
  EuiIconTip,
} from '@elastic/eui';
import useFilters, { FILTERS_SCHEDULE_FILTER_ID } from '@/common/hooks/useFilters/useFilters';
import { find } from 'lodash';

interface ScheduleFiltersProps {
  demandPartnerOptions?: any[];
  selectedDemandPartner?: any[];
  onChangeDemandPartner: (demandPartnerName: any) => void;
  fieldProviderOptions?: any[];
  selectedFieldProvider?: any[];
  onChangeFieldProvider: (name: any) => void;
  onlyShowWorkingToggle: boolean;
  setOnlyShowWorkingToggle: (callback: any) => void;
  shiftCoverageToggle: boolean;
  setShiftCoverageToggle: (callback: any) => void;
  onClearAll: () => void;
}

const ONLY_SHOW_WORKING_KEY = 'only_show_working';
const SHOW_SHIFT_COVERAGE_KEY = 'show_shift_coverage';
const DEMAND_PARTNER_FILTER_KEY = 'demand_partner_key';
const FIELD_PROVIDER_FILTER_KEY = 'field_provider_filter_key';

export const ScheduleFilters: React.FC<ScheduleFiltersProps> = ({
  demandPartnerOptions,
  selectedDemandPartner,
  onChangeDemandPartner,
  fieldProviderOptions,
  selectedFieldProvider,
  onChangeFieldProvider,
  onlyShowWorkingToggle,
  setOnlyShowWorkingToggle,
  shiftCoverageToggle,
  setShiftCoverageToggle,
  onClearAll,
}) => {
  const [showFilters, setShowFilters] = useState(false);
  const { filters, updateFilter, clearFilterByKey } = useFilters();

  const resetFilters = useCallback(() => {
    setOnlyShowWorkingToggle(false);
    setShiftCoverageToggle(true);
    onChangeDemandPartner([]);
    onChangeFieldProvider([]);
    setShowFilters(false);
  }, []);

  const filtersKeys = filters?.map((f) => `${f.id}-${f.key}-${f.value}`).join(',');
  useEffect(() => {
    if (filters?.length) {
      filters.forEach((f) => {
        if (f.id === FILTERS_SCHEDULE_FILTER_ID) {
          switch (f.key) {
            case ONLY_SHOW_WORKING_KEY:
              setOnlyShowWorkingToggle(f.value);
              break;
            case SHOW_SHIFT_COVERAGE_KEY:
              setShiftCoverageToggle(f.value);
              break;
            case DEMAND_PARTNER_FILTER_KEY:
              onChangeDemandPartner(f.value);
              break;
            case FIELD_PROVIDER_FILTER_KEY:
              onChangeFieldProvider(f.value);
              break;
            default:
              break;
          }
        }
      });

      const enableFilters = find(filters, (f) => f.id === FILTERS_SCHEDULE_FILTER_ID);
      setShowFilters(!!enableFilters);
    } else {
      resetFilters();
    }
  }, [filtersKeys]);

  const shouldDisplayClearAll = find(filters, (f) => f.id === FILTERS_SCHEDULE_FILTER_ID);

  return (
    <>
      <EuiFlexGroup style={{ placeContent: 'space-between' }}>
        <EuiFlexItem>
          <div>
            <EuiButtonEmpty
              isSelected={showFilters}
              iconType="filter"
              style={{ color: '#343741', fontFamily: 'Inter', fontWeight: 700 }}
              onClick={() => {
                setShowFilters((isOn) => !isOn);
              }}
            >
              Filters
            </EuiButtonEmpty>
          </div>
        </EuiFlexItem>
        {shouldDisplayClearAll && (
          <EuiFlexItem style={{ alignItems: 'end' }}>
            <div>
              <EuiButtonEmpty
                isSelected={showFilters}
                style={{ fontSize: '13px', fontFamily: 'Inter', fontWeight: 700 }}
                onClick={() => {
                  clearFilterByKey(FILTERS_SCHEDULE_FILTER_ID);
                  resetFilters();
                  onClearAll();
                }}
              >
                Clear All
              </EuiButtonEmpty>
            </div>
          </EuiFlexItem>
        )}
      </EuiFlexGroup>
      <EuiSpacer size="m" />
      {showFilters && (
        <EuiFlexGrid>
          <EuiFlexItem style={{ width: '382px' }}>
            <EuiFormRow label="Demand Partner">
              <EuiComboBox
                placeholder="Select a Demand Partner"
                singleSelection={{ asPlainText: true }}
                options={demandPartnerOptions || []}
                selectedOptions={selectedDemandPartner}
                onChange={(selected) => {
                  updateFilter(FILTERS_SCHEDULE_FILTER_ID, DEMAND_PARTNER_FILTER_KEY, selected);
                  onChangeDemandPartner(selected);
                }}
              />
            </EuiFormRow>
          </EuiFlexItem>
          <EuiFlexItem style={{ width: '382px' }}>
            <EuiFormRow
              label={
                <EuiFlexGroup alignItems="center" justifyContent="center" gutterSize="none" responsive={false}>
                  <EuiFlexItem grow={false}>
                    <span>Role</span>
                  </EuiFlexItem>
                  <EuiFlexItem style={{ marginLeft: '2px' }} grow={false}>
                    <EuiIconTip
                      size="s"
                      color="#737373"
                      type="iInCircle"
                      content="Field Provider, Nurse Practitioner, Social Worker, Witness"
                    />
                  </EuiFlexItem>
                </EuiFlexGroup>
              }
            >
              <EuiComboBox
                placeholder="Select"
                options={fieldProviderOptions}
                selectedOptions={selectedFieldProvider}
                onChange={(selected) => {
                  updateFilter(FILTERS_SCHEDULE_FILTER_ID, FIELD_PROVIDER_FILTER_KEY, selected);
                  onChangeFieldProvider(selected);
                }}
              />
            </EuiFormRow>
          </EuiFlexItem>

          <EuiFlexItem style={{ flexDirection: 'row', alignItems: 'end' }}>
            <EuiFlexItem style={{ marginRight: '1rem' }}>
              <EuiCheckbox
                id="only_show_working"
                label="Only show working"
                checked={onlyShowWorkingToggle}
                onChange={() => {
                  setOnlyShowWorkingToggle((toggle) => {
                    updateFilter(FILTERS_SCHEDULE_FILTER_ID, ONLY_SHOW_WORKING_KEY, !toggle);
                    return !toggle;
                  });
                }}
              />
            </EuiFlexItem>
            <EuiFlexItem>
              <EuiCheckbox
                id="show_shift_coverage"
                label="Show shift coverage "
                checked={shiftCoverageToggle}
                onChange={() => {
                  setShiftCoverageToggle((toggle) => {
                    updateFilter(FILTERS_SCHEDULE_FILTER_ID, SHOW_SHIFT_COVERAGE_KEY, !toggle);
                    return !toggle;
                  });
                }}
              />
            </EuiFlexItem>
          </EuiFlexItem>
        </EuiFlexGrid>
      )}

      <EuiSpacer size="m" />
    </>
  );
};
