import { fireEvent, render, waitFor } from '@testing-library/react';
import { mount } from 'enzyme';
import React from 'react';
import { PaginationFooter } from './PaginationFooter';

const numberOfRows = 5;
const totalPages = 12;
const humanActivePage = 3;
const onPageClickSpy = jest.fn();

const TestComponent = () => (
  <PaginationFooter
    perPage={numberOfRows}
    pageCount={totalPages}
    activePage={humanActivePage}
    onPageClick={onPageClickSpy}
  />
);

describe('<PaginationFooter />', () => {
  it('delegates props to the EuiPagination component', () => {
    const comp = mount(<TestComponent />);

    expect(comp.find('EuiPagination').props()).toEqual(
      expect.objectContaining({
        pageCount: totalPages,
        activePage: humanActivePage - 1,
      }),
    );
  });

  it('displays page selections and changes page properly', () => {
    const { getByText } = render(<TestComponent />);

    fireEvent.click(getByText(4));
    expect(onPageClickSpy).toHaveBeenCalledWith(4, numberOfRows);
  });

  it('displays row selection options and changes selection properly', () => {
    const { getByText } = render(<TestComponent />);

    fireEvent.click(getByText('Rows per page: 5'));
    waitFor(() => fireEvent.click(getByText(50)));

    waitFor(() => expect(onPageClickSpy).toHaveBeenCalledWith(1, 50));
  });
});
