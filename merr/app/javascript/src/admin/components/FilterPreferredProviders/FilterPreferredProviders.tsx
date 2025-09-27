import React, { useMemo, useState } from 'react';
import { EuiPopover, EuiFilterGroup, EuiIcon, EuiCheckbox } from '@elastic/eui';
import { OptionsProps } from '@/common/components/SelectableFilter/SelectableFilter';
import { FilterButton, Selectable } from './components/FilterComponent';

export default ({
  items,
  setItems,
  isLoading,
}: {
  items: OptionsProps[];
  setItems: (items: OptionsProps[]) => void;
  isLoading: boolean;
}) => {
  const [isPopoverOpen, setIsPopoverOpen] = useState(false);

  const onButtonClick = () => {
    setIsPopoverOpen(!isPopoverOpen);
  };
  const closePopover = () => {
    setIsPopoverOpen(false);
  };

  const button = (
    <FilterButton
      iconType="arrowDown"
      onClick={onButtonClick}
      isSelected={isPopoverOpen}
      numFilters={items.filter((item) => item.checked !== 'off').length}
      hasActiveFilters={!!items.find((item) => item.checked === 'on')}
      numActiveFilters={items.filter((item) => item.checked === 'on').length}
    >
      <EuiIcon type="dot" />
      Preferred Providers
    </FilterButton>
  );

  const isFull = useMemo(() => items.filter((i) => i.checked === 'on').length === items.length, [JSON.stringify(items)]);

  return (
    <EuiFilterGroup>
      <EuiPopover
        id="filterGroupPopover"
        button={button}
        isOpen={isPopoverOpen}
        closePopover={closePopover}
        panelPaddingSize="none"
      >
        <Selectable
          searchable
          searchProps={{
            placeholder: 'Filter list',
            compressed: true,
          }}
          aria-label="preferredProviders"
          options={items}
          onChange={(newOptions) => setItems(newOptions)}
          isLoading={isLoading}
          loadingMessage="Loading filters"
          emptyMessage="No filters available"
          noMatchesMessage="No filters found"
        >
          {(list) => {
            return (
              <div style={{ width: 300 }}>
                <div style={{ width: '288px', height: '33px', padding: '4px 12px', borderBottom: '1px solid #eef2f7' }}>
                  <EuiCheckbox
                    id="selectAll"
                    label="Select All"
                    checked={isFull}
                    onChange={() => {
                      let selectAll = null;
                      if (isFull) {
                        selectAll = items.map((i) => ({ ...i, checked: undefined }));
                      } else {
                        selectAll = items.map((i) => ({ ...i, checked: 'on' }));
                      }
                      setItems(selectAll);
                    }}
                  />
                </div>
                {list}
              </div>
            );
          }}
        </Selectable>
      </EuiPopover>
    </EuiFilterGroup>
  );
};
