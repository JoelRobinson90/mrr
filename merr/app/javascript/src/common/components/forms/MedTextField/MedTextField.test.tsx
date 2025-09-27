import React from 'react';
import { fireEvent, act } from '@testing-library/react';

import { MedTextField } from './MedTextField';
import { renderTestForm } from '@/../test_utils/helpers/renderTestForm';

describe('MedTextField', () => {
  const fields = (
    <>
      <MedTextField name="patient.first_name" label="First Name" />
    </>
  );
  it('submits its value', async () => {
    const formOptions = {
      defaultValues: { patient: { first_name: '' } },
    };

    const { getByLabelText, submitForm, submitSpy } = renderTestForm(fields, formOptions);

    act(() => {
      fireEvent.input(getByLabelText('First Name'), { target: { value: 'Erik' } });
    });

    await submitForm();
    expect(submitSpy).toHaveBeenCalledWith({ patient: { first_name: 'Erik' } });
  });

  it('renders with its default value', () => {
    const formOptions = {
      defaultValues: { patient: { first_name: 'Existing Name' } },
    };

    const { getByLabelText } = renderTestForm(fields, formOptions);
    expect(getByLabelText('First Name')).toHaveValue('Existing Name');
  });
});
