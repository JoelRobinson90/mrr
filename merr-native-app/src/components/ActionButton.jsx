import React from 'react';
import PropTypes from 'proptypes';
import {
  Pressable, Text, Flex, Icon, Box,
} from 'native-base';
import { Ionicons } from '@expo/vector-icons';

import Book from '../../assets/icons/fi_book.svg';
import Calendar from '../../assets/icons/fi_calendar.svg';
import Info from '../../assets/icons/fi_info-circle.svg';
import Close from '../../assets/icons/fi_x-circle.svg';

function ActionButton({
  onPress, count, iconName, label,
}) {
  let IconSvg = null;
  switch (iconName) {
    case 'reschedule':
      IconSvg = Calendar;
      break;
    case 'cancel':
      IconSvg = Close;
      break;
    case 'report':
      IconSvg = Info;
      break;
    default:
      IconSvg = Book;
      break;
  }
  return (
    <Pressable
      onPress={onPress}
      variant="visitAction"
      colorScheme="warmGray"
      withoutBorder={count !== null}
    >
      <Flex
        direction="row"
        alignItems="center"
        justifyContent="space-between"
      >
        <Flex direction="row" align="center">
          <IconSvg />
          <Text pl="24px" pr="24px" variant="text" fontWeight="500">
            {label}
          </Text>
          {count !== null ? (
            <Box bg="muted.600" borderRadius="2px">
              <Text color="#FFFFFF" px="4px" py="2px">
                {count}
              </Text>
            </Box>
          ) : null}
        </Flex>
        <Icon
          as={Ionicons}
          name="chevron-forward-outline"
          size="5"
          color="muted.700"
        />
      </Flex>
    </Pressable>
  );
}

ActionButton.propTypes = {
  count: PropTypes.number,
  onPress: PropTypes.func.isRequired,
  label: PropTypes.string.isRequired,
  iconName: PropTypes.string.isRequired,
};

ActionButton.defaultProps = {
  count: null,
};

export default ActionButton;
