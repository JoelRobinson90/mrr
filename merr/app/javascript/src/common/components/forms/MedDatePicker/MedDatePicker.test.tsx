import React, { useState } from 'react';
import { fireEvent, render, act, waitFor } from '@testing-library/react';
import { FormProvider, useForm } from 'react-hook-form';
import timezoneMock from 'timezone-mock';

import { MedDatePicker } from './MedDatePicker';

describe('MedDatePicker', () => {
  it('displays the initial value date', () => {
    const TestComponent = () => {
      const form = useForm({
        defaultValues: {
          patient: {
            date_of_birth: '1987-03-13',
          },
        },
      });

      return (
        <FormProvider {...form}>
          <MedDatePicker name="patient.date_of_birth" label="DOB" />
        </FormProvider>
      );
    };

    const { getByRole } = render(<TestComponent />);

    expect(getByRole('textbox')).toHaveValue('03/13/1987');
  });

  it('submits its changed value', async () => {
    const submitSpy = jest.fn();

    const TestComponent = () => {
      const [submitted, setSubmitted] = useState(false);

      const form = useForm({
        defaultValues: {
          patient: {
            date_of_birth: '1987-03-13',
          },
        },
      });
      const { handleSubmit } = form;

      const onSubmit = (values) => {
        setSubmitted(true);
        submitSpy(values);
      };

      return (
        <FormProvider {...form}>
          <form onSubmit={handleSubmit(onSubmit)}>
            <MedDatePicker name="patient.date_of_birth" label="DOB" />
            <button type="submit">Submit</button>
          </form>
          {submitted && <span role="submitted" />}
        </FormProvider>
      );
    };

    const { getByRole, findByRole, findByText, getByText } = render(<TestComponent />);

    fireEvent.focus(getByRole('textbox'));
    await findByText('March');

    act(() => {
      fireEvent.click(getByText('31'));
      fireEvent.submit(getByText('Submit'));
    });

    expect(await findByRole('submitted')).toBeTruthy();
    expect(submitSpy).toHaveBeenCalledWith({ patient: { date_of_birth: '1987-03-31' } });
  });

  it('works with an alternate date format', async () => {
    const dateFormat = 'YYYY-MM-DD';

    const submitSpy = jest.fn();

    const TestComponent = () => {
      const [submitted, setSubmitted] = useState(false);

      const form = useForm({
        defaultValues: {
          patient: {
            date_of_birth: '1987-03-13',
          },
        },
      });
      const { handleSubmit } = form;

      const onSubmit = (values) => {
        setSubmitted(true);
        submitSpy(values);
      };

      return (
        <FormProvider {...form}>
          <form onSubmit={handleSubmit(onSubmit)}>
            <MedDatePicker name="patient.date_of_birth" label="DOB" dateFormat={dateFormat} />
            <button type="submit">Submit</button>
          </form>
          {submitted && <span role="submitted" />}
        </FormProvider>
      );
    };

    const { getByRole, findByRole, findByText, getByText } = render(<TestComponent />);

    const field = getByRole('textbox');
    expect(field).toHaveValue('1987-03-13');

    fireEvent.focus(field);
    await findByText('March');

    act(() => {
      fireEvent.click(getByText('31'));
      fireEvent.submit(getByText('Submit'));
    });

    expect(await findByRole('submitted')).toBeTruthy();
    expect(submitSpy).toHaveBeenCalledWith({ patient: { date_of_birth: '1987-03-31' } });
  });

  describe('time select', () => {
    const start_time = '2021-06-18T17:00:00.000Z';
    const submitMock = jest.fn();

    const TestComponent = () => {
      const form = useForm({
        defaultValues: {
          appointment: {
            start_time,
          },
        },
      });

      return (
        <form onSubmit={form.handleSubmit(submitMock)}>
          <FormProvider {...form}>
            <MedDatePicker
              name="appointment.start_time"
              showTimeSelect
              showTimeSelectOnly
              dateFormat="hh:mm a"
              timeFormat="hh:mm a"
            />
            <button type="submit">Submit</button>
          </FormProvider>
        </form>
      );
    };

    beforeAll(() => {
      timezoneMock.register('US/Eastern');
    });

    afterAll(() => {
      timezoneMock.unregister();
    });

    afterEach(() => {
      submitMock.mockReset();
    });

    it('shows initial time in the browser time zone', () => {
      const { getByRole } = render(<TestComponent />);
      expect(getByRole('textbox')).toHaveValue('01:00 pm');
    });

    it('saves selected time in UTC', () => {
      const { getByRole, getByText } = render(<TestComponent />);

      fireEvent.click(getByRole('textbox'));
      fireEvent.click(getByText('11:00 am'));
      expect(getByRole('textbox')).toHaveValue('11:00 am');

      fireEvent.submit(getByText('Submit'));
      waitFor(() => {
        expect(submitMock).toHaveBeenCalledWith({
          appointment: {
            start_time: '2021-06-18T15:00:00Z',
          },
        });
      });
    });
  });
});
