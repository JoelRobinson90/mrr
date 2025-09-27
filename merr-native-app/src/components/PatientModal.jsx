/* eslint-disable camelcase */
import React from 'react';
import PropTypes from 'prop-types';
import { Modal, Flex, Text, Box, Pressable, Button } from 'native-base';
import PatientDetails from './PatientDetails';
import DisplayRow from './DisplayRow';
import useDeviceType from '../hooks/useDeviceType';
import openExternalUrl from '../helpers/openExternalUrl';

import Close from '../../assets/icons/fi_x.svg';

export default function PatientModal({
  modalVisible,
  visit,
  setModalVisible,
  actionsAllowed = true,
}) {
  const { isMobile } = useDeviceType();
  const { first_name, last_name, demandPartner, programs, phone_number } =
    visit?.patient || {
      first_name: '',
      last_name: '',
    };

  return (
    <Modal
      transparent={false}
      isOpen={modalVisible}
      onClose={setModalVisible}
      avoidKeyboard
      justifyContent="flex-end"
      size="full"
    >
      <Modal.Content>
        <Modal.Header borderBottomWidth="0">
          <Flex direction="row" justify="space-between" align="center">
            <Pressable onPress={setModalVisible}>
              <Close />
            </Pressable>
            <Text
              variant="title"
              fontSize="main"
            >{`${first_name} ${last_name}`}</Text>
            <Box variant="patientInitials" bg="muted.100">
              {`${first_name[0]}${last_name[0]}`}
            </Box>
          </Flex>
        </Modal.Header>
        <Modal.Body px="0" py="0">
          <Flex h="700px">
            <Box px="16px">
              <Text variant="title" fontSize="main" pb="16px">
                Info
              </Text>
              <PatientDetails visit={visit} actionsAllowed={actionsAllowed} />
              {phone_number && (
                <>
                  {isMobile && (
                    <Button
                      testID="callButton"
                      w="99px"
                      h="31px"
                      p="0"
                      variant="main"
                      outline
                      _text={{
                        fontSize: 'note',
                      }}
                      onPress={() =>
                        openExternalUrl('tel://', visit?.patient?.phone_number)
                      }
                    >
                      Call
                    </Button>
                  )}
                  <Text variant="note" fontSize="note" my="16px">
                    Phone Number: {phone_number}
                  </Text>
                </>
              )}
            </Box>
            <Box h="4px" bg="muted.300" />
            <Box px="16px" mb="24px">
              <Text variant="title" fontSize="main" py="16px">
                Medical
              </Text>
              <DisplayRow label="Demand Partner" value={demandPartner?.name} />
              <DisplayRow
                label="Program(s)"
                value={programs?.map((p) => p.name).join(', ')}
              />
              <DisplayRow
                label="Service Instructions"
                value={visit?.service_instructions}
              />
            </Box>
          </Flex>
        </Modal.Body>
      </Modal.Content>
    </Modal>
  );
}

PatientModal.propTypes = {
  visit: PropTypes.shape({
    patient: PropTypes.shape(),
    service_instructions: PropTypes.string,
  }).isRequired,
  modalVisible: PropTypes.bool.isRequired,
  setModalVisible: PropTypes.func.isRequired,
};
