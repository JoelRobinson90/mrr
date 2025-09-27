import * as React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function ProfileIcon({ color }) {
  return (
    <Svg
      width={32}
      height={32}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <Path
        d="M24 25v-2a4 4 0 0 0-4-4h-8a4 4 0 0 0-4 4v2M16 15a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

ProfileIcon.propTypes = {
  color: PropTypes.string.isRequired,
};

export default ProfileIcon;
