import React from 'react';
import { render } from '../src/helpers/testingLibrary';

import App from '../App';

describe('App component', () => {
  it('should render correctly', () => {
    const component = render(<App />);
    expect(component).toBeTruthy();
  });
});
