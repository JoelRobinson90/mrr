import React from 'react';
import PropTypes from 'proptypes';
import { Menu } from 'native-base';
import { useNavigation } from '@react-navigation/native';
import IconButton from './DotsIcon';

function DotMenu({ visit, bg }) {
  const navigation = useNavigation();
  return (
    <Menu
      w="190"
      placement="bottom right"
      trigger={(props) => IconButton({ bg, ...props })}
    >
      {/* <Menu.Item>Reschedule visit</Menu.Item> */}
      <Menu.Item
        onPress={() => navigation.navigate('CancelVisit', {
          visit,
        })}
      >
        Cancel Visit
      </Menu.Item>
      {/* <Menu.Item>Report problem</Menu.Item> */}
    </Menu>
  );
}

DotMenu.propTypes = {
  visit: PropTypes.shape().isRequired,
  bg: PropTypes.bool,
};

DotMenu.defaultProps = {
  bg: false,
};

export default DotMenu;
