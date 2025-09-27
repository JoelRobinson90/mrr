/* eslint-disable camelcase */
import React from 'react';
import PropTypes from 'prop-types';
import { VStack, Box, Text, Flex, Pressable } from 'native-base';
import { useNavigation } from '@react-navigation/native';
import standardizeStatus from '../helpers/displayStatus';
import getDateWithTimeZone from '../helpers/getDateWithTimeZone';

import UsersIcons from '../../assets/icons/fi_users.svg';

function VisitCard({ visit, setAndOpenModal, actionsAllowed = () => {} }) {
  const navigation = useNavigation();
  const { first_name, last_name, address } = visit?.patient || {};

  const {
    city, state, zipcode, address_line_one, address_line_two, timezone,
  } = address || {};

  const addressLineOneWithoutNumber = address_line_one
    .split(' ')
    .slice(1)
    .join(' ');

  const status =
    visit?.confirmed && visit?.status === 'scheduled'
      ? 'confirmed'
      : visit?.status;

  return (
    <Box
      style={{
        shadowOpacity: 0.25,
        shadowRadius: 3,
        shadowOffset: { width: 2, height: 1.84 },
      }}
    >
      <Pressable
        testID="visitCard"
        onPress={() =>
          navigation.navigate('Visit', {
            visit,
            actionsAllowed: actionsAllowed(),
          })
        }
        w="full"
        py="10px"
        px="20px"
        mb="16px"
        rounded="8px"
        overflow="hidden"
        borderWidth="1"
        variant="visitCard"
        colorScheme={status}
        justifyContent="center"
      >
        <VStack>
          <Flex flexDirection="row" justifyContent="space-between">
            <Box w="55%">
              <Text variant="badge" colorScheme={status}>
                {standardizeStatus(status) || 'No status'}
              </Text>
              <Box mt="10px" mb="4px">
                <Text variant="text">
                  {`${city || ''} ${state || ''}, ${zipcode || ''}`}
                </Text>
                <Box mt="4px" />
                <Text variant="text">
                {`${
                    actionsAllowed()
                      ? address_line_one
                      : addressLineOneWithoutNumber
                  } ${address_line_two || ''}`}
                </Text>
              </Box>
              <Pressable
                onPress={() =>
                  navigation.navigate('Preview', {
                    visit,
                    showStreetNumber: actionsAllowed(),
                  })
                }
              >
                <Text variant="link">Preview Location</Text>
              </Pressable>
            </Box>
            <Flex direction="column" justifyContent="space-between">
              <Flex align="center">
                <Text fontSize="main" fontWeight="500">
                  {getDateWithTimeZone(visit?.cx_start, 'h:mm a z', timezone)}
                </Text>
              </Flex>
              <Pressable mt="10px" onPress={() => setAndOpenModal(visit)}>
                <Flex align="center">
                  <Box variant="patientInitials">{`${first_name[0]}${last_name[0]}`}</Box>
                </Flex>
              </Pressable>
              <Pressable mt="4px" onPress={() => setAndOpenModal(visit)}>
                <Flex align="center">
                  <Text
                    variant="text"
                    fontSize="note"
                  >
                    {`${first_name} ${last_name[0]}.`}
                  </Text>
                </Flex>
              </Pressable>
            </Flex>
          </Flex>
          <Flex justify="center" align="center" mt="10px" direction="row">
            {visit?.providers.length > 1 && (
              <Box mr="8px">
                <UsersIcons />
              </Box>
            )}
            <Text variant="text" fontWeight="500">
              {visit.visit_type.name}
            </Text>
          </Flex>
        </VStack>
      </Pressable>
    </Box>
  );
}

VisitCard.propTypes = {
  visit: PropTypes.shape({
    patient: PropTypes.shape().isRequired,
    status: PropTypes.string.isRequired,
    start_time: PropTypes.string.isRequired,
    visit_type: PropTypes.shape().isRequired,
    confirmed: PropTypes.bool.isRequired,
    cx_start: PropTypes.string.isRequired,
    cx_end: PropTypes.string.isRequired,
    providers: PropTypes.arrayOf(PropTypes.shape()),
  }),
  setAndOpenModal: PropTypes.func.isRequired,
};

VisitCard.defaultProps = {
  visit: {
    providers: [],
  },
};

export default VisitCard;
