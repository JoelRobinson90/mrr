import React from 'react';
import { fireEvent, act } from '@testing-library/react';

import { MedCheckbox } from './MedCheckbox';
import { renderTestForm } from '@/../test_utils/helpers/renderTestForm';

describe('MedCheckbox', () => {
  const fields = (
    <>
      <MedCheckbox name="box1" label="This is box 1" />
      <MedCheckbox name="box2" label="This is box 2" />
    </>
  );

  const formOptions = {
    defaultValues: { box1: true, box2: false },
  };
  it('renders and submits its default values', async () => {
    const { getByLabelText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    expect(getByLabelText('This is box 1')).toBeChecked();
    expect(getByLabelText('This is box 2')).not.toBeChecked();

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ box1: true, box2: false });
  });

  it('changes values and submits new ones', async () => {
    const { getByLabelText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    act(() => {
      fireEvent.click(getByLabelText('This is box 1'));
      fireEvent.click(getByLabelText('This is box 2'));
    });

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ box1: false, box2: true });
  });
});
