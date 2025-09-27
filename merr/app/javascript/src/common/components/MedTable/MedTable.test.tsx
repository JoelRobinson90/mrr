import React from 'react';
import { MedTable } from './MedTable';
import { screen, render, within } from '@testing-library/react';

describe('<MedTable />', () => {
  describe('Given the items are provided', () => {
    it('renders without error', async () => {
      const items = [
        {
          name: 'Harrison',
          number: '1',
          phoneNumber: '(541) 754-3010',
          location: 'Nairobi, Kenya',
          partner: {
            name: 'partner-1',
          },
        },
        {
          name: 'Erik',
          number: '2',
          phoneNumber: '(541) 754-3011',
          location: 'Dallas, Texas',
          partner: {
            name: 'partner-2',
          },
        },
      ];

      const columns = [
        {
          field: 'name',
          name: 'Name',
          sortable: true,
        },
        {
          field: 'number',
          name: 'NO#',
          sortable: true,
        },
        {
          field: 'phoneNumber',
          name: 'Phone Number',
        },
        {
          field: 'location',
          name: 'City/State',
        },
        {
          field: 'partner',
          name: 'Partner',
        },
        {
          field: 'status',
          name: 'Status',
        },
      ];

      render(<MedTable items={items} columns={columns} />);

      expect(screen.getByRole('table')).toBeInTheDocument();

      // test for rows rendering
      items.forEach((item) => {
        const row = screen.getByText(item.name).closest('tr');
        const utils = within(row);

        expect(utils.getByText(item.name)).toBeInTheDocument();
      });
    });
  });
});
