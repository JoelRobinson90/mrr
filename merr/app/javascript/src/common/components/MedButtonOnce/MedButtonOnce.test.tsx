import { EuiButton } from '@elastic/eui';
import { act, fireEvent, render, waitFor } from '@testing-library/react';
import React from 'react';
import { MedButtonOnce } from './MedButtonOnce';

describe('<MedButtonOnce />', () => {
  it('shows loadingText when button was clicked', async () => {
    const { getByText, queryByText, container } = render(
      <MedButtonOnce loadingText="Button was clicked" onClick={() => void 0}>
        Click me
      </MedButtonOnce>,
    );

    expect(getByText('Click me')).toBeInTheDocument();
    expect(container.querySelector('.euiButton .euiLoadingSpinner')).not.toBeInTheDocument();

    act(() => {
      fireEvent.click(getByText('Click me'));
    });

    await waitFor(() => {
      expect(queryByText('Click me')).not.toBeInTheDocument();
    });

    expect(getByText('Button was clicked')).toBeInTheDocument();
    expect(container.querySelector('.euiButton .euiLoadingSpinner')).toBeInTheDocument();
  });

  it('can only be clicked once', async () => {
    const onceOnClick = jest.fn();
    const normalButtonOnClick = jest.fn();

    const { getByText } = render(
      <>
        <MedButtonOnce onClick={onceOnClick}>Once button text</MedButtonOnce>
        <EuiButton onClick={normalButtonOnClick}>Normal button text</EuiButton>
      </>,
    );

    act(() => {
      fireEvent.click(getByText('Once button text'));
    });

    await waitFor(() => {
      expect(onceOnClick).toHaveBeenCalled();
    });

    act(() => {
      fireEvent.click(getByText('Loading...'));
      fireEvent.click(getByText('Loading...'));

      fireEvent.click(getByText('Normal button text'));
      fireEvent.click(getByText('Normal button text'));
      fireEvent.click(getByText('Normal button text'));
    });

    expect(normalButtonOnClick).toHaveBeenCalledTimes(3);

    expect(onceOnClick).toHaveBeenCalledTimes(1);
  });
});
