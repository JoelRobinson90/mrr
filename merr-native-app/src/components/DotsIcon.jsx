import React from 'react';
import PropTypes from 'proptypes';
import { ThreeDotsIcon, Pressable, Flex } from 'native-base';

function DotsIcon(props) {
  const { bg } = props;
  return (
    <Pressable
      // eslint-disable-next-line react/jsx-props-no-spreading
      {...props}
      w="50px"
      h="50px"
      display="flex"
      justifyContent="center"
      alignItems="flex-end"
    >
      <Flex
        bg={bg ? 'white' : 'transparent'}
        w="30px"
        h="30px"
        borderRadius="100px"
        align="center"
        justify="center"
      >
        <ThreeDotsIcon
          size="18px"
          color="muted.700"
          style={{ transform: [{ rotate: '90deg' }] }}
        />
      </Flex>
    </Pressable>
  );
}

DotsIcon.propTypes = {
  bg: PropTypes.bool,
};

DotsIcon.defaultProps = {
  bg: false,
};

export default DotsIcon;
