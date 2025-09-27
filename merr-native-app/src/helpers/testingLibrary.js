import {
  render, fireEvent, act, waitFor, cleanup,
} from '@testing-library/react-native';
import { NativeBaseProvider } from 'native-base';
import { NavigationContainer } from '@react-navigation/native';
import React from 'react';
import PropTypes from 'prop-types';

const metrics = {
  frame: {
    width: 320,
    height: 640,
    x: 0,
    y: 0,
  },
  insets: {
    left: 0,
    right: 0,
    bottom: 0,
    top: 0,
  },
};

function AllTheProviders({ children }) {
  return (
    <NativeBaseProvider initialWindowMetrics={metrics}>
      <NavigationContainer>
        {children}
      </NavigationContainer>
    </NativeBaseProvider>
  );
}

AllTheProviders.propTypes = {
  children: PropTypes.element.isRequired,
};

const renderWithProviders = (
  ui,
  options,
) => render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react-native';
export {
  renderWithProviders, fireEvent, act, waitFor, cleanup,
};
