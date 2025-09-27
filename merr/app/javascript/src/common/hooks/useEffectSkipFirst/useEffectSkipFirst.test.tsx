import React, { useState } from 'react';
import { fireEvent, render } from '@testing-library/react';
import { useEffectSkipFirst } from './useEffectSkipFirst';

describe('useEffectSkipFirst()', () => {
  const effectSpy = jest.fn();

  afterEach(() => {
    effectSpy.mockReset();
  });

  const TestComponent = () => {
    const [counter, setCounter] = useState(0);

    useEffectSkipFirst(effectSpy, [counter]);

    return <button onClick={() => setCounter(counter + 1)}>Increment</button>;
  };

  it('does not run on first render', () => {
    render(<TestComponent />);
    expect(effectSpy).not.toHaveBeenCalled();
  });

  it('runs when deps change', () => {
    const { getByText } = render(<TestComponent />);
    fireEvent.click(getByText('Increment'));
    fireEvent.click(getByText('Increment'));
    fireEvent.click(getByText('Increment'));
    expect(effectSpy).toHaveBeenCalledTimes(3);
  });
});
