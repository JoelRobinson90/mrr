import React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function LightBlueCircle({ style }) {
  return (
    <Svg style={style} width="184" height="106" viewBox="0 0 184 106" fill="none" xmlns="http://www.w3.org/2000/svg">
      <Path d="M89.1354 16.3729L0 106H157.215L167.73 95.408C189.423 73.5831 189.423 38.2062 167.73 16.3813C146.038 -5.46044 110.828 -5.46044 89.1354 16.3813" fill="#3FB9DC" />
    </Svg>
  );
}

LightBlueCircle.propTypes = {
  style: PropTypes.shape({}),
};

LightBlueCircle.defaultProps = {
  style: {},
};

export default LightBlueCircle;
