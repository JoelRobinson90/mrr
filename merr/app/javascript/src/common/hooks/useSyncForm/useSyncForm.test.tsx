import React, { useState } from 'react';
import { EuiButton } from '@elastic/eui';
import { act, fireEvent, render, waitFor } from '@testing-library/react';
import { MedTextField } from '@/common/components/forms';
import { useSyncForm } from './useSyncForm';
import { setInputValue } from '@/../test_utils/helpers/renderTestForm';
import { submitSyncForm } from '@/common/components/SyncForm/SyncForm-utils';
import { SyncForm } from '@/common/components/SyncForm/SyncForm';

jest.mock('@/common/components/SyncForm/SyncForm-utils', () => ({
  submitSyncForm: jest.fn(),
}));

describe('useSyncForm()', () => {
  afterEach(() => {
    // @ts-ignore
    submitSyncForm.mockClear();
  });

  it('returns SyncForm props', async () => {
    const TestComponent = () => {
      const { syncFormProps, loading } = useSyncForm({
        url: '/test/form/endpoint',
        method: 'post',
        formOptions: {
          defaultValues: {
            testFields: {
              one: 'foo',
            },
          },
        },
      });

      return (
        <SyncForm {...syncFormProps}>
          <MedTextField name="testFields.one" />
          <MedTextField name="testFields.two" />
          {loading ? <p>Form is loading</p> : null}
          <EuiButton type="submit" isLoading={loading}>
            Submit
          </EuiButton>
        </SyncForm>
      );
    };

    const { container, getByText, queryByText } = render(<TestComponent />);

    expect(container.querySelector('input[name="testFields.one"]')).toHaveValue('foo');
    expect(queryByText('Form is loading')).not.toBeInTheDocument();

    act(() => {
      setInputValue(container.querySelector('input[name="testFields.two"]'), 'bar');
      fireEvent.click(getByText('Submit'));
    });

    await waitFor(() => {
      expect(getByText('Form is loading')).toBeInTheDocument();
      expect(submitSyncForm).toHaveBeenCalledWith(
        '/test/form/endpoint',
        'post',
        {
          testFields: {
            one: 'foo',
            two: 'bar',
          },
        },
        {},
      );
    });
  });

  it('does not submit if disabled', async () => {
    const TestComponent = () => {
      const [disabled, setDisabled] = useState(true);
      const [counter, setCounter] = useState(0);

      const { syncFormProps } = useSyncForm({
        url: '/test/form/endpoint',
        method: 'post',
        formOptions: {
          defaultValues: {
            testFields: {
              one: 'foo',
            },
          },
        },
        disabled,
      });

      return (
        <SyncForm {...syncFormProps}>
          <MedTextField name="testFields.one" />
          <EuiButton type="button" onClick={() => setDisabled(false)}>
            Enable form
          </EuiButton>
          <EuiButton type="button" onClick={() => setCounter(counter + 1)}>
            Counter: {counter}
          </EuiButton>
          <EuiButton type="submit" isDisabled={disabled}>
            Submit
          </EuiButton>
        </SyncForm>
      );
    };

    const { getByText } = render(<TestComponent />);

    expect(getByText('Submit').closest('button')).toBeDisabled();

    act(() => {
      fireEvent.click(getByText('Submit'));
      fireEvent.click(getByText('Counter: 0'));
    });

    await waitFor(() => {
      expect(getByText('Counter: 1')).toBeInTheDocument();
      expect(submitSyncForm).not.toHaveBeenCalled();
    });

    act(() => {
      fireEvent.click(getByText('Enable form'));
    });

    await waitFor(() => {
      expect(getByText('Submit').closest('button')).not.toBeDisabled();
    });

    act(() => {
      fireEvent.click(getByText('Submit'));
    });

    await waitFor(() => {
      expect(submitSyncForm).toHaveBeenCalledTimes(1);
    });
  });

  it('calls the onFormSubmit function if provided instead of submitting the form', async () => {
    const onFormSubmitSpy = jest.fn();

    const TestComponent = () => {
      const { syncFormProps } = useSyncForm({
        url: '/test/form/endpoint',
        method: 'post',
        formOptions: {
          defaultValues: {
            testFields: {
              one: 'foo',
            },
          },
        },
        onFormSubmit: onFormSubmitSpy,
      });

      return (
        <SyncForm {...syncFormProps}>
          <MedTextField name="testFields.one" />
          <EuiButton type="submit">Submit</EuiButton>
        </SyncForm>
      );
    };

    const { getByText } = render(<TestComponent />);

    act(() => {
      fireEvent.click(getByText('Submit'));
    });

    await waitFor(() => {
      expect(onFormSubmitSpy).toHaveBeenCalledWith({
        testFields: {
          one: 'foo',
        },
      });
      expect(submitSyncForm).not.toHaveBeenCalled();
    });
  });

  it('returns a submit function that will submit to the endpoint', async () => {
    const TestComponent = () => {
      const { syncFormProps, submit } = useSyncForm({
        url: '/test/form/endpoint',
        method: 'post',
        formOptions: {
          defaultValues: {
            testFields: {
              one: 'foo',
            },
          },
        },
        onFormSubmit: (_values) => {
          // submit a different payload
          submit({
            differentFields: {
              one: 'bar',
            },
          });
        },
      });

      return (
        <SyncForm {...syncFormProps}>
          <MedTextField name="testFields.one" />
          <EuiButton type="submit">Submit</EuiButton>
        </SyncForm>
      );
    };

    const { getByText } = render(<TestComponent />);

    act(() => {
      fireEvent.click(getByText('Submit'));
    });

    await waitFor(() => {
      expect(submitSyncForm).toHaveBeenCalledWith(
        '/test/form/endpoint',
        'post',
        {
          differentFields: {
            one: 'bar',
          },
        },
        {},
      );
    });
  });

  it('can only be submitted once natively', async () => {
    const TestComponent = () => {
      const { syncFormProps } = useSyncForm({
        url: '/test/form/endpoint',
        method: 'post',
        formOptions: {
          defaultValues: {
            testFields: {
              one: 'foo',
            },
          },
        },
      });

      return (
        <SyncForm {...syncFormProps}>
          <MedTextField name="testFields.one" />
        </SyncForm>
      );
    };

    const { container } = render(<TestComponent />);

    fireEvent.submit(container.querySelector('form'));

    await waitFor(() => {
      expect(submitSyncForm).toHaveBeenCalled();
    });

    fireEvent.submit(container.querySelector('form'));
    fireEvent.submit(container.querySelector('form'));
    fireEvent.submit(container.querySelector('form'));

    await waitFor(() => {
      expect(submitSyncForm).toHaveBeenCalledTimes(1);
    });
  });
});
