import React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function GreenBgCircle({ style }) {
  return (
    <Svg style={style} width="75" height="189" viewBox="0 0 75 189" fill="none" xmlns="http://www.w3.org/2000/svg">
      <Path d="M0 0V189C18.7654 187.801 37.171 180.008 51.5236 165.587C82.8255 134.178 82.8255 83.19 51.5236 51.7811L0 0Z" fill="#00B38F" />
    </Svg>
  );
}

GreenBgCircle.propTypes = {
  style: PropTypes.shape({}),
};

GreenBgCircle.defaultProps = {
  style: {},
};

export default GreenBgCircle;
