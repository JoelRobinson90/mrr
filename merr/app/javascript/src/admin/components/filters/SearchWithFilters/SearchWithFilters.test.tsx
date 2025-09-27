import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react';
import { SearchWithFilters } from './SearchWithFilters';
import { getUpdatedQueryPath } from '@/common/utils/queries/queries';
import timezoneMock from 'timezone-mock';

jest.mock('@/common/utils/queries/queries', () => ({
  getUpdatedQueryPath: jest.fn(() => '/updated/query/path/result'),
}));

describe('admin/components/SearchWithFilters', () => {
  beforeAll(() => {
    timezoneMock.register('US/Eastern');
  });

  afterAll(() => {
    timezoneMock.unregister();
  });

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

  it('updates timezone in URL when selecting date', async () => {
    const options = {
      available_tags: [
        { label: 'tag1', value: 'tag1' },
        { label: 'tag2', value: 'tag2' },
      ],
      start_date: true,
    };

    const filters = {
      tag: '',
      start: '',
      end: '',
    };

    const { getByPlaceholderText } = render(
      <SearchWithFilters options={options} filters={filters} query={''} onSearch={() => void 0} />,
    );

    fireEvent.change(getByPlaceholderText('Start'), '01/01/2020');
    fireEvent.change(getByPlaceholderText('End'), '01/02/2020');

    waitFor(() => {
      expect(getUpdatedQueryPath).toHaveBeenCalledWith({
        start: '2020-01-01',
        end: '2020-01-02',
        timezone: 'America/New_York',
      });
      expect(window.location.assign).toHaveBeenCalledWith('/updated/query/path/result');
    });
  });
});
