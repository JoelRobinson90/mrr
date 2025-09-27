import * as React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function ActivityIcon({ color }) {
  return (
    <Svg
      width={32}
      height={32}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <Path
        d="M26 16h-4l-3 9-6-18-3 9H6"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

ActivityIcon.propTypes = {
  color: PropTypes.string.isRequired,
};

export default ActivityIcon;
