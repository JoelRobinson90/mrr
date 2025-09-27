import React, { useState } from 'react';
import PropTypes from 'proptypes';
import {
  Flex, Text, Button, Modal,
} from 'native-base';
import { StatusBar } from 'expo-status-bar';
import * as Linking from 'expo-linking';

function GeolocationPermissions({ permissionDenied, requestPermissions }) {
  const [showModal, setShowModal] = useState(false);

  const closeModal = () => {
    requestPermissions();
    setShowModal(false);
  };

  return (
    <Flex align="center">
      {/* eslint-disable-next-line react/style-prop-object */}
      <StatusBar style="dark" />
      <Text mt="80px" variant="title" color="muted.600" fontSize="main">
        We need your location data
      </Text>
      <Text mt="16px" variant="note" fontSize="main" w="320px" textAlign="center">
        We need your location for safety reasons to ensure we know the location of our
        field providers while they are in the field and in patient homes.
      </Text>
      {permissionDenied ? (
        <Button
          testID="buttonOpenPhoneSettings"
          mt="216"
          p="0"
          variant="main"
          w="166px"
          _text={{
            fontSize: 'text',
          }}
          onPress={async () => {
            await Linking.openSettings();
            setShowModal(true);
          }}
        >
          Open Phone Settings
        </Button>
      ) : (
        <Button
          testID="buttonRequestPermissions"
          mt="216"
          p="0"
          variant="main"
          w="45%"
          _text={{
            fontSize: 'text',
          }}
          onPress={requestPermissions}
        >
          Request Permissions
        </Button>
      )}
      <Modal isOpen={showModal} onClose={closeModal}>
        <Modal.Content maxWidth="400px">
          <Modal.CloseButton />
          <Modal.Header>Location Permissions</Modal.Header>
          <Modal.Body>
            <Text>In order to use this application, it is necessary to know your location.</Text>
          </Modal.Body>
          <Modal.Footer>
            <Button.Group space={2}>
              <Button onPress={closeModal}>
                Continue
              </Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </Flex>
  );
}

GeolocationPermissions.propTypes = {
  permissionDenied: PropTypes.bool.isRequired,
  requestPermissions: PropTypes.func.isRequired,
};

export default GeolocationPermissions;
