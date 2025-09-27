import React from 'react';
import PropTypes from 'proptypes';
import { Flex, Text } from 'native-base';

function DisplayRow({ label, value }) {
  return (
    <Flex direction="row" pb="16px" flexWrap="wrap">
      <Text variant="text" fontSize="main">
        {label}
        :
        {' '}
        <Text variant="text" fontSize="main" colorScheme={label === 'Email' ? 'cyan' : ''}>
          {value}
        </Text>
      </Text>
    </Flex>
  );
}

DisplayRow.propTypes = {
  label: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
  ]),
};

DisplayRow.defaultProps = {
  value: '' || 0,
};

export default DisplayRow;
