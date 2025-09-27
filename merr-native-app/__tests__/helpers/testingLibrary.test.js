import React from 'react';
import { Text } from 'react-native';
import { renderWithProviders } from '../../src/helpers/testingLibrary';

describe('AllTheProviders', () => {
  it('renders children with providers', () => {
    const { getByText } = renderWithProviders(
      <Text testID="test-component">Hello, World!</Text>,
    );
    expect(getByText('Hello, World!')).toBeDefined();
  });
});
