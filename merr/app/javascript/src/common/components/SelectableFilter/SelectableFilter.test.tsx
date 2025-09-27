import React from 'react';
import { screen, render, prettyDOM, fireEvent, waitFor } from '@testing-library/react';
import { SelectableFilter } from './SelectableFilter';
import { act } from 'react-dom/test-utils';

describe('<SelectableFilter />', () => {
  it('renders correctly', async () => {
    const data = [
      {
        label: 'Option',
        value: 'opt1',
      },
      {
        label: 'Option 2',
        value: 'opt2',
      },
      {
        label: 'Option 3',
        value: 'opt3',
      },
    ];
    const handleOnSelectFilter = (key, _searchString, _displayString) => {
      console.log(key);
    };
    const mockedFunction = jest.fn(handleOnSelectFilter);
    const { container } = render(
      <SelectableFilter
        data={data}
        title="Filter"
        dataTestId="selectable-filter"
        select="opt1"
        handleOnSelectFilter={mockedFunction}
      />,
    );
    console.log(prettyDOM(container));

    // clicking clear filter X icon
    act(() => {
      fireEvent.click(container.querySelector('.euiPopover__anchor svg'));
    });
    expect(mockedFunction).toHaveBeenCalledWith('filter', '', '');

    act(() => {
      fireEvent.click(container.querySelector('button'));
      waitFor(() => {
        expect(screen.getByPlaceholderText('Search')).toBeVisible();
        console.log('QUery ->');
        console.log(screen.getByTestId('selectable-filter'));
        expect(screen.getByTestId('selectable-filter')).toBeVisible();
        console.log(prettyDOM(screen.getByTestId('selectable-filter').querySelector('.euiSelectableList__list')));
      });
    });
  });
});
