import { fireEvent, render } from '@testing-library/react';
import React from 'react';
import { PaginationParams, usePagination } from './usePagination';
import { getUpdatedQueryPath } from '@/common/utils/queries/queries';

jest.mock('@/common/utils/queries/queries', () => ({
  getUpdatedQueryPath: jest.fn(() => '/updated/query/path/result'),
}));

describe('usePagination', () => {
  // TODO: how to DRY this mock?
  const oldWindowLocation = window.location;
  const locationAssignMock = jest.fn();

  beforeAll(() => {
    delete window.location;

    window.location = {
      ...oldWindowLocation,
      assign: locationAssignMock,
    };
  });

  beforeEach(() => {
    locationAssignMock.mockReset();
  });

  afterAll(() => {
    window.location = oldWindowLocation;
  });

  type Props = {
    pagination: PaginationParams;
  };

  const PaginationTestComponent: React.FC<Props> = ({ pagination }) => {
    const { pageCount, perPage, activePage, onPageClick } = usePagination(pagination);

    return (
      <>
        <span data-testid="pageCount">{pageCount}</span>
        <span data-testid="perPage">{perPage}</span>
        <span data-testid="activePage">{activePage}</span>
        <button onClick={() => onPageClick(4, 75)}>Change Page</button>
      </>
    );
  };

  it('passes returns the correct page numbers', () => {
    const { getByTestId } = render(
      <PaginationTestComponent
        pagination={{
          current_page: 3,
          total_pages: 13,
          rows_per_page: 100,
        }}
      />,
    );

    expect(getByTestId('activePage')).toHaveTextContent('3');
    expect(getByTestId('pageCount')).toHaveTextContent('13');
    expect(getByTestId('perPage')).toHaveTextContent('100');
  });

  it('directs the user to the new query path', () => {
    const { getByText } = render(
      <PaginationTestComponent
        pagination={{
          current_page: 3,
          total_pages: 13,
          rows_per_page: 100,
        }}
      />,
    );

    fireEvent.click(getByText('Change Page'));
    expect(getUpdatedQueryPath).toHaveBeenCalledWith({ page: 4, rows_per_page: 75 });
    expect(window.location.assign).toHaveBeenCalledWith('/updated/query/path/result');
  });
});
