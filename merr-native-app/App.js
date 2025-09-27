import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { NativeBaseProvider } from 'native-base';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ApolloProvider } from '@apollo/client';

import HomeScreen from './src/screens/home/home';
import VisitScreen from './src/screens/visit/visit';
import DashboardScreen from './src/screens/dashboard/dashboard';
import PreviewScreen from './src/screens/preview/preview';
import VisitSummaryScreen from './src/screens/visit/visitSummary';
import VisitNotesScreen from './src/screens/visit/visitNotes';
import { AuthProvider } from './src/context/auth';
import theme from './src/constants/theme';
import { apolloClient } from './src/graphql/client';
import CancelVisitScreen from './src/screens/visit/cancel/cancelVisitScreen';
import CustomBackButton from './src/components/CustomBackButton';
import Sentry from './src/service/sentry';
import ErrorBoundary from './src/screens/crash/container';
import useCheckAppVersion from './src/hooks/useCheckAppVersion';

const Stack = createNativeStackNavigator();

// Maintains color mode despite refresh
const colorModeManager = {
  get: async () => {
    try {
      const val = await AsyncStorage.getItem('@my-app-color-mode');
      return val === 'dark' ? 'light' : 'light';
    } catch (e) {
      Sentry.Native.captureException(e);
      return 'light';
    }
  },
  set: async (value) => {
    try {
      await AsyncStorage.setItem('@my-app-color-mode', value);
    } catch (e) {
      Sentry.Native.captureException(e);
      // do something here
    }
  },
};

export default function App() {
  useCheckAppVersion();

  const screenOptions = { headerShown: false };

  return (
    <ApolloProvider client={apolloClient}>
      <AuthProvider>
        <NativeBaseProvider theme={theme} colorModeManager={colorModeManager}>
          <ErrorBoundary>
            <NavigationContainer>
              <Stack.Navigator>
                <Stack.Screen
                  options={screenOptions}
                  name="Home"
                  component={HomeScreen}
                />
                <Stack.Screen
                  options={screenOptions}
                  name="Dashboard"
                  component={DashboardScreen}
                />
                <Stack.Screen
                  name="Visit"
                  component={VisitScreen}
                  options={{
                    title: '',
                    // eslint-disable-next-line react/no-unstable-nested-components
                    headerLeft: () => <CustomBackButton path="Dashboard" />,
                  }}
                />
                <Stack.Screen
                  name="Preview"
                  component={PreviewScreen}
                  options={{
                    headerShown: true,
                    headerTransparent: true,
                    title: '',
                    headerLeft: CustomBackButton,
                  }}
                />
                <Stack.Screen
                  name="Summary"
                  component={VisitSummaryScreen}
                  options={screenOptions}
                />
                <Stack.Screen options={screenOptions} name="Notes" component={VisitNotesScreen} />
                <Stack.Screen
                  name="CancelVisit"
                  component={CancelVisitScreen}
                  options={{
                    title: '',
                    headerLeft: CustomBackButton,
                  }}
                />
              </Stack.Navigator>
            </NavigationContainer>
          </ErrorBoundary>
        </NativeBaseProvider>
      </AuthProvider>
    </ApolloProvider>
  );
}
