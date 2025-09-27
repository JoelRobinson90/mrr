import { renderTestForm } from '@/../test_utils/helpers/renderTestForm';
import { fireEvent } from '@testing-library/react';
import React from 'react';
import { MedMaskedInput } from './MedMaskedInput';

describe('MedMaskedInput', () => {
  it('shows a mask when focused on', () => {
    const { getByRole } = renderTestForm(<MedMaskedInput name="dob" mask="99/99/9999" label="Date of birth" />);
    const field = getByRole('textbox');

    expect(field).toHaveValue('');

    fireEvent.focus(field);
    expect(field).toHaveValue('__/__/____');
  });

  it('fills in mask with allowed characters', () => {
    const { getByRole } = renderTestForm(<MedMaskedInput name="dob" mask="99/99/9999" label="Date of birth" />);
    const field = getByRole('textbox');

    fireEvent.change(field, { target: { value: '03131987' } });
    expect(field).toHaveValue('03/13/1987');
  });
});
