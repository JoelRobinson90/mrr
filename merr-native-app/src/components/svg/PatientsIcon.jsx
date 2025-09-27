import * as React from 'react';
import PropTypes from 'prop-types';
import Svg, {
  G, Path, Defs, ClipPath,
} from 'react-native-svg';

function PatientsIcon({ color }) {
  return (
    <Svg
      width={33}
      height={32}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <G
        clipPath="url(#a)"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <Path d="M27.5 25v-2a4 4 0 0 0-3-3.87M21.5 25v-2a4 4 0 0 0-4-4h-8a4 4 0 0 0-4 4v2M20.5 7.13a4 4 0 0 1 0 7.75M13.5 15a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z" />
      </G>
      <Defs>
        <ClipPath id="a">
          <Path fill="#fff" transform="translate(4.5 4)" d="M0 0h24v24H0z" />
        </ClipPath>
      </Defs>
    </Svg>
  );
}

PatientsIcon.propTypes = {
  color: PropTypes.string.isRequired,
};

export default PatientsIcon;
