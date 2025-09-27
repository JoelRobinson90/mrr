import React from 'react';
import PropTypes from 'proptypes';
import { useNavigation } from '@react-navigation/native';
import { Pressable } from 'native-base';
import ArrowLeft from '../../assets/icons/fi_chevron-left.svg';

function CustomBackButton({ path }) {
  const navigation = useNavigation();
  return (
    <Pressable onPress={() => {
      if (path) {
        navigation.navigate(path);
      } else {
        navigation.goBack();
      }
    }}
    >
      <ArrowLeft />
    </Pressable>
  );
}

CustomBackButton.propTypes = {
  path: PropTypes.string,
};

CustomBackButton.defaultProps = {
  path: '',
};

export default CustomBackButton;
