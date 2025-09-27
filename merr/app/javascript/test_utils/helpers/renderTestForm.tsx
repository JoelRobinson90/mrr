import { fireEvent, render, waitFor } from '@testing-library/react';
import React, { useState } from 'react';
import { FormProvider, useForm, UseFormOptions } from 'react-hook-form';

export const renderTestForm = (fields: JSX.Element, formOptions: UseFormOptions = {}) => {
  const submitSpy = jest.fn();

  const TestComponent = () => {
    const [submitCount, setSubmitCount] = useState(0);

    const form = useForm(formOptions);
    const { handleSubmit } = form;

    const onSubmit = (values) => {
      setSubmitCount((count) => count + 1);
      submitSpy(values);
    };

    return (
      <FormProvider {...form}>
        <form onSubmit={handleSubmit(onSubmit)}>
          {fields}
          <button type="submit">Submit</button>
        </form>
        <span role="submitted">{submitCount}</span>
      </FormProvider>
    );
  };

  const methods = render(<TestComponent />);

  let submitCount = 0;

  const submitForm = async () => {
    submitCount++;
    fireEvent.submit(methods.getByRole('button'));
    await waitFor(() => expect(methods.getByRole('submitted')).toHaveTextContent(submitCount.toString()));
  };

  return { submitSpy, submitForm, ...methods };
};

export const setInputValue = (selector: Node, value: string | number) => {
  return fireEvent.input(selector, { target: { value } });
};

export const submitFormBy = (button: Node) => fireEvent.submit(button);
