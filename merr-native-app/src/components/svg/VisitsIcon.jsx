import * as React from 'react';
import PropTypes from 'prop-types';
import Svg, { Path } from 'react-native-svg';

function VisitsIcon({ color }) {
  return (
    <Svg
      width={32}
      height={32}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <Path
        d="m6 21 10 5 10-5M6 16l10 5 10-5M16 6 6 11l10 5 10-5-10-5Z"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

VisitsIcon.propTypes = {
  color: PropTypes.string.isRequired,
};

export default VisitsIcon;
