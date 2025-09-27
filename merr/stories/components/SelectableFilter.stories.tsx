import React, { useState } from 'react';
import { Story, Meta } from '@storybook/react';
import { SelectableFilter, SelectableFilterProps } from '@/common/components/SelectableFilter/SelectableFilter';
import { EuiFlexGroup, EuiFlexItem } from '@elastic/eui';
export default {
  title: 'Components/SelectableFilter',
  component: SelectableFilter,
} as Meta;
const data = [
  { label: 'test', value: 'test' },
  { label: 'test2', value: 'test2' },
  { label: 'test3', value: 'test3' },
];
const defaultFilters = {
  status: '',
  tag: 'test',
  partner: ['test', 'test2'],
};
const Template: Story<SelectableFilterProps> = () => {
  const [selectFilter, setSelectFilter] = useState(defaultFilters);
  const handleOnSelectFilter = (filter, title) => {
    setSelectFilter({
      ...selectFilter,
      [title]: filter[title],
    });
  };
  return (
    <EuiFlexGroup gutterSize="s" alignItems="center">
      <EuiFlexItem grow={false}>
        <SelectableFilter
          data={data}
          title={'Tag'}
          iconType={'controlsHorizontal'}
          handleOnSelectFilter={handleOnSelectFilter}
          select={selectFilter.tag}
        />
      </EuiFlexItem>
      <EuiFlexItem grow={false}>
        <SelectableFilter
          data={data}
          title={'Status'}
          handleOnSelectFilter={handleOnSelectFilter}
          select={selectFilter.status}
        />
      </EuiFlexItem>
      <EuiFlexItem grow={false}>
        <SelectableFilter
          data={data}
          title={'Partner'}
          handleOnSelectFilter={handleOnSelectFilter}
          select={selectFilter.partner}
          singleSelection={false}
        />
      </EuiFlexItem>
    </EuiFlexGroup>
  );
};

export const Default = Template.bind({});
