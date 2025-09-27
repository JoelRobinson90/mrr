import { currentUserAdminMock } from '@/../test_utils/graphql/mocks';
import { useFlashToast } from '@/common/components/FlashToast/FlashToast';
import { MockedProvider } from '@apollo/client/testing';
import { fireEvent, render, within } from '@testing-library/react';
import React from 'react';
import { withAdminLayout } from './AdminLayout';

describe('withAdminLayout()', () => {
  it('makes flash messages available to the component', async () => {
    const TestPageComponent = () => {
      const { addNotice } = useFlashToast();
      return <button onClick={() => addNotice('notice is shown')}>Click to show notice</button>;
    };
    const TestPageWithAdminLayout = withAdminLayout(TestPageComponent);
    const { container } = render(
      <MockedProvider mocks={[currentUserAdminMock]}>
        <TestPageWithAdminLayout layout_props={{}} />
      </MockedProvider>,
    );
    const { getByText, findByText } = within(container);

    fireEvent.click(getByText('Click to show notice'));
    expect(await findByText('notice is shown')).toBeInTheDocument();
  });
});
