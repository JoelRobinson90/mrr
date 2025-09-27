import React, { useState, useCallback } from 'react';
import { StatusBar } from 'expo-status-bar';
import { Animated, useWindowDimensions, BackHandler } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';

import {
  Box, Pressable, Text, useColorModeValue, Flex,
} from 'native-base';

import { SceneMap, TabView } from 'react-native-tab-view';
import {
  add, endOfDay, startOfDay, sub,
} from 'date-fns';
import VisitsList from './components/visitsList';
import GeolocationPermissions from '../../components/GeolocationPermissions';
import theme from '../../constants/theme';
import useGeolocation from '../../hooks/useGeolocation';

function UpcomingVisits() {
  const startTime = startOfDay(new Date()).toISOString();
  const endTime = endOfDay(add(new Date(), { months: 1 })).toISOString();
  return <VisitsList startTime={startTime} endTime={endTime} />;
}

function PastVisits() {
  const startTime = startOfDay(sub(new Date(), { days: 30 })).toISOString();
  const endTime = endOfDay(sub(new Date(), { days: 1 })).toISOString();
  return <VisitsList startTime={startTime} endTime={endTime} />;
}

const renderScene = SceneMap({
  upcoming: UpcomingVisits,
  past: PastVisits,
});

const renderTabBar = (props, index, setIndex) => {
  const { routes } = props.navigationState;
  const { muted } = theme.colors;

  useFocusEffect(
    useCallback(() => {
      const onBackPress = () => true;

      BackHandler.addEventListener('hardwareBackPress', onBackPress);

      return () => BackHandler.removeEventListener('hardwareBackPress', onBackPress);
    }, []),
  );

  return (
    <Box flexDirection="row">
      {routes?.map(({ title }, i) => {
        const color = index === i ? muted['900'] : muted['600'];
        const borderColor = index === i
          ? useColorModeValue('muted.900')
          : useColorModeValue('coolGray.200', 'gray.400');
        return (
          <Pressable
            key={title}
            borderBottomWidth="1"
            borderColor={borderColor}
            w="50%"
            h="31px"
            onPress={() => {
              setIndex(i);
            }}
          >
            <Flex align="center">
              <Animated.Text style={{ color, fontSize: 14, fontWeight: '500' }}>
                {title}
              </Animated.Text>
            </Flex>
          </Pressable>
        );
      })}
    </Box>
  );
};

function VisitsTabs() {
  const layout = useWindowDimensions();
  const { isLocationGranted, permissionDenied, requestPermissions } = useGeolocation();

  const [index, setIndex] = useState(0);
  const [routes] = useState([
    { key: 'upcoming', title: 'Upcoming' },
    { key: 'past', title: 'Past' },
  ]);

  if (!isLocationGranted) {
    return (
      <GeolocationPermissions
        permissionDenied={permissionDenied}
        requestPermissions={requestPermissions}
      />
    );
  }

  return (
    <Flex bg="white" flexGrow={1}>
      {/* eslint-disable-next-line react/style-prop-object */}
      <StatusBar style="dark" />
      <Text variant="title" ml="16px" my="16px">
        Visits List
      </Text>
      <TabView
        navigationState={{ index, routes }}
        renderScene={renderScene}
        renderTabBar={(props) => renderTabBar(props, index, setIndex)}
        onIndexChange={setIndex}
        initialLayout={{ width: layout.width }}
      />
    </Flex>
  );
}

export default VisitsTabs;
