import React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function DarkBlueCircle({ style }) {
  return (
    <Svg style={style} width="119" height="126" viewBox="0 0 119 126" fill="none" xmlns="http://www.w3.org/2000/svg">
      <Path d="M75.8396 0H0C0.776816 1.67491 1.55363 3.32631 2.3481 4.97771C17.7903 36.8362 39.5235 65.6622 65.9941 89.1814C82.0895 103.539 99.9386 115.904 119 126V47.0149C115.999 44.6465 113.074 42.2018 110.214 39.6512C97.1256 28.0268 85.5439 14.6452 75.8396 0Z" fill="#20407C" />
    </Svg>
  );
}

DarkBlueCircle.propTypes = {
  style: PropTypes.shape({}),
};

DarkBlueCircle.defaultProps = {
  style: {},
};

export default DarkBlueCircle;
