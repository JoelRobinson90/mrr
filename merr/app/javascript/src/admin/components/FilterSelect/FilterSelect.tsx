import { htmlIdGenerator, EuiFilterButton, EuiFilterSelectItem, EuiPopover } from '@elastic/eui';
import React, { useMemo, useState } from 'react';

type Value = string | number | null;

type Props = {
  options: FilterSelectOption[];
  selectedValue: Value;
  placeholder?: string;
  clearable?: boolean;
  onSelect?: (value: Value) => void;
};

export type FilterSelectOption = {
  value: Value;
  text: string;
};

export const FilterSelect: React.FC<Props> = ({ options, selectedValue, placeholder, clearable, onSelect }) => {
  const [isOpen, setIsOpen] = useState(false);

  const id = useMemo(htmlIdGenerator(), []);

  const selectedOption = useMemo(() => (selectedValue ? options.find((o) => o.value === selectedValue) : null), [
    selectedValue,
    options.map((o) => o.value).join(','),
  ]);

  const cleared = !selectedOption;

  let clearedSelectItem;
  if (clearable || cleared) {
    clearedSelectItem = (
      <EuiFilterSelectItem checked={cleared ? 'on' : null} onClick={() => onSelect && onSelect(null)}>
        (none)
      </EuiFilterSelectItem>
    );
  }

  return (
    <EuiPopover
      id={id}
      button={
        <EuiFilterButton iconType="arrowDown" onClick={() => setIsOpen(true)}>
          {selectedOption?.text || placeholder}
        </EuiFilterButton>
      }
      isOpen={isOpen}
      closePopover={() => setIsOpen(false)}
      panelPaddingSize="none"
      anchorPosition="downLeft"
    >
      <div className="euiFilterSelect__items">
        {clearedSelectItem}
        {options.map(({ text, value }) => (
          <EuiFilterSelectItem
            key={value}
            checked={value === selectedValue ? 'on' : null}
            onClick={() => onSelect(value)}
          >
            {text}
          </EuiFilterSelectItem>
        ))}
      </div>
    </EuiPopover>
  );
};
