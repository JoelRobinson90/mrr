import React from 'react';
import PropTypes from 'proptypes';
import {
  Spinner, Heading, HStack,
} from 'native-base';

function Loading({ message }) {
  return (
    <HStack space={2} justifyContent="center">
      <Spinner accessibilityLabel="Loading posts" />
      <Heading color="primary.500" fontSize="md">
        {message}
      </Heading>
    </HStack>
  );
}

Loading.propTypes = {
  message: PropTypes.string.isRequired,
};

export default Loading;
