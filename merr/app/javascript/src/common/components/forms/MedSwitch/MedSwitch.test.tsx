import React from 'react';
import { fireEvent, act } from '@testing-library/react';

import { MedSwitch } from './MedSwitch';
import { renderTestForm } from '@/../test_utils/helpers/renderTestForm';

describe('MedSwitch', () => {
  const fields = (
    <>
      <MedSwitch name="toggle" label="Toggle me!" />
    </>
  );

  it('submits its value', async () => {
    const formOptions = {
      defaultValues: { toggle: false },
    };

    const { getByText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    act(() => {
      fireEvent.click(getByText('Toggle me!'));
    });

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ toggle: true });
  });

  it('renders with its default value', () => {
    const formOptions = {
      defaultValues: { toggle: true },
    };

    const { getByText, getByRole } = renderTestForm(fields, formOptions);
    expect(getByRole('switch')).toHaveAttribute('aria-checked', 'true');

    act(() => {
      fireEvent.click(getByText('Toggle me!'));
    });

    expect(getByRole('switch')).toHaveAttribute('aria-checked', 'false');
  });
});
