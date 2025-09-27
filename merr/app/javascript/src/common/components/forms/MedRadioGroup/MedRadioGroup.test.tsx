import React from 'react';
import { fireEvent, act } from '@testing-library/react';

import { MedRadioGroup } from './MedRadioGroup';
import { renderTestForm } from '@/../test_utils/helpers/renderTestForm';

describe('MedRadioGroup', () => {
  const radios = [
    {
      id: 'option1',
      label: 'This is radio 1',
    },
    {
      id: 'option2',
      label: 'This is radio 2',
    },
  ];

  const fields = (
    <>
      <MedRadioGroup name="selected" options={radios} />
    </>
  );

  const formOptions = {
    defaultValues: { selected: 'option1' },
  };
  it('renders and submits its default values', async () => {
    const { getByLabelText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    expect(getByLabelText('This is radio 1')).toBeChecked();
    expect(getByLabelText('This is radio 2')).not.toBeChecked();

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ selected: 'option1' });
  });

  it('changes values and submits new ones', async () => {
    const { getByLabelText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    act(() => {
      fireEvent.click(getByLabelText('This is radio 2'));
    });

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ selected: 'option2' });
  });
});
