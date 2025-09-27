import React from 'react';
import PropTypes from 'proptypes';
import {
  /* Box, */ Flex,
} from 'native-base';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import VisitsTabs from '../visit/visitsTabs';

import PatientsIcon from '../../components/svg/PatientsIcon';
import VisitsIcon from '../../components/svg/VisitsIcon';
import ActivityIcon from '../../components/svg/ActivityIcon';
import ProfileIcon from '../../components/svg/ProfileIcon';
// import ComingSoon from '../../components/ComingSoon';

import theme from '../../constants/theme';

// import Menu from '../../../assets/icons/fi_menu.svg';
import Logo from '../../../assets/icons/fi_logo.svg';
// import Bell from '../../../assets/icons/fi_bell.svg';
import ProfileScreen from '../profile/profileScreen';

function TabBarIcon({ route, color }) {
  switch (route.name) {
    case 'Visits':
      return <VisitsIcon color={color} />;
    case 'Patients':
      return <PatientsIcon color={color} />;
    case 'Activity':
      return <ActivityIcon color={color} />;
    default:
      return <ProfileIcon color={color} />;
  }
}

TabBarIcon.propTypes = {
  route: PropTypes.any.isRequired,
  color: PropTypes.any.isRequired,
};

const Tab = createBottomTabNavigator();

function DashboardScreen() {
  const { cyan, muted } = theme.colors;

  // const headerLeft = () => (
  //   <Box ml="16px">
  //     <Menu />
  //   </Box>
  // );

  const headerTitle = () => (
    <Flex align="center" justify="center">
      <Logo />
    </Flex>
  );

  // const headerRight = () => (
  //   <Box mr="16px">
  //     <Bell />
  //   </Box>
  // );

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ color }) => TabBarIcon({
          route,
          color,
        }),
        tabBarActiveTintColor: cyan['600'],
        tabBarInactiveTintColor: muted['600'],
        // headerLeft,
        // headerRight,
        headerTitle,
        headerTitleAlign: 'center',
      })}
    >
      <Tab.Screen name="Visits" component={VisitsTabs} />
      {/* <Tab.Screen name="Patients" component={ComingSoon} />
      <Tab.Screen name="Activity" component={ComingSoon} /> */}
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

export default DashboardScreen;
