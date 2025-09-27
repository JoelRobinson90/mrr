import React, { useState, useEffect, FC } from 'react';
import { EuiButton, EuiButtonProps, EuiIcon, EuiPopover, EuiSelectable } from '@elastic/eui';
import { EuiSelectableOptionCheckedType } from '@elastic/eui/src/components/selectable/selectable_option';
import { map, filter, includes, isArray } from 'lodash';

interface StyledButtonProps extends EuiButtonProps {
  select: number;
}

export interface OptionsProps {
  label: string;
  value?: string;
  checked?: EuiSelectableOptionCheckedType;
}

const createOptions = (options: OptionsProps[], select: string | string[]) => {
  return [
    ...options.map((option) => {
      const checked = includes(select, option.value);
      return {
        label: option.label,
        value: option.value,
        checked: checked ? 'on' : undefined,
      };
    }),
  ];
};

export interface SelectableFilterProps {
  data: OptionsProps[];
  iconType?: string;
  select: string | string[];
  title: string;
  singleSelection?: boolean;
  handleOnSelectFilter: (key, searchString, displayString) => void;
  dataTestId?: string;
}

export const SelectableFilter: FC<SelectableFilterProps> = ({
  data,
  iconType,
  select,
  title,
  singleSelection = true,
  handleOnSelectFilter,
  dataTestId,
}) => {
  const [options, setOptions] = useState([]);
  const [isPopoverOpen, setIsPopoverOpen] = useState(false);
  const key = title.toLocaleLowerCase().replace(/ /g, '_');

  useEffect(() => {
    const optionsData = createOptions(data, select);
    setOptions(optionsData);
  }, [JSON.stringify(data)]);

  const closePopover = () => {
    setIsPopoverOpen(false);

    const selectedOptions = map(filter(options, { checked: 'on' }), 'value');
    const searchString = selectedOptions.join('|');
    const displayString = selectedOptions.join(',');
    handleOnSelectFilter(key, searchString, displayString);
  };

  const onButtonClick = () => {
    setIsPopoverOpen(!isPopoverOpen);
  };

  const clearSelect = () => {
    handleOnSelectFilter(key, '', '');
    const currentOptions = [...options];
    currentOptions.forEach((opt) => (opt.checked = undefined));
    setOptions(currentOptions);
  };

  const selectedLabel = filter(options, (o) => {
    if (isArray(select)) {
      return select.includes(o.value);
    }
    return o.value === select;
  });
  const button = (
    <div style={{ position: 'relative' }}>
      {select && (
        <EuiIcon
          data-test-id={`clearSelect-${title}`}
          style={{ cursor: 'pointer', position: 'absolute', top: 0, bottom: 0, left: 10, margin: 'auto', zIndex: 100 }}
          type="cross"
          onClick={clearSelect}
        />
      )}
      <EuiButton
        style={{
          paddingLeft: 15,
          border: `2px solid ${select ? '#a7ace4' : '#eeeff7'}`,
          background: 'white',
          color: '#676767',
        }}
        iconType={iconType}
        data-testid={dataTestId}
        onClick={onButtonClick}
      >
        {title}
        {selectedLabel?.length ? `: ${selectedLabel.map((s) => s.label)?.join(', ')}` : ''}
      </EuiButton>
    </div>
  );

  const handleChange = (newOptions: OptionsProps[]) => {
    setOptions(newOptions);
  };

  const listProps = { bordered: true };
  const searchProps = { placeholder: 'Search' };

  return (
    <EuiPopover
      hasArrow={false}
      panelPaddingSize="none"
      button={button}
      isOpen={isPopoverOpen}
      closePopover={closePopover}
      panelStyle={{ marginTop: 10 }}
    >
      <EuiSelectable
        searchable
        searchProps={searchProps}
        options={options}
        onChange={(newOptions) => handleChange(newOptions)}
        singleSelection={singleSelection}
        listProps={listProps}
        data-testid={`${dataTestId}-popover`}
      >
        {(list, search) => (
          <>
            {search}
            {list}
          </>
        )}
      </EuiSelectable>
    </EuiPopover>
  );
};
