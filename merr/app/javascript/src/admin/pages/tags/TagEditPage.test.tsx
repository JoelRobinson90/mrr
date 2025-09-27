import React from 'react';
import { TagEditPageComponent } from './TagEditPage';
import { render } from '@testing-library/react';
import { AdminLayoutProps } from '@/admin/components/AdminLayout/AdminLayout';

describe('<TagEditPage />', () => {
  xit('renders without error', async () => {
    const tag = {
      id: 1,
      name: 'Testerino',
      color: '#FFFFFF',
      group: 'Appointment',
      description: 'test',
    };

    const layoutProps: AdminLayoutProps = {
      breadcrumbs: [
        {
          text: 'Tags',
          href: '#',
        },
        {
          text: `${tag.name}`,
          href: '#',
        },
      ],
    };

    const { getByText } = render(<TagEditPageComponent tag={tag} />);

    // Will throw an error if not found
    // TODO: This was finding the layout breadcrumb before; fix this test
    getByText('Testerino');
  });
});

// @TODO: test validations
