import React from 'react';
import PropTypes from 'proptypes';
import {
  Flex,
  Button,
  Spacer,
  Box,
  Text,
} from 'native-base';

import CrashImg from '../../../assets/images/crash-img.svg';

function CrashScreen({ goBack }) {
  return (
    <Flex p="24px" justify="space-between" h="full" align="center">
      <Box mt="54px" />
      <CrashImg />
      <Text mt="24px" mb="16px" variant="title">Oops! something went wrong</Text>
      <Text
        textAlign="center"
        maxW="312px"
        variant="label"
        fontWeight="400"
        colorScheme="muted"
      >
        We&apos;re already working on fixing this, on the meantime please try again
      </Text>
      <Spacer />
      <Button
        width="100%"
        mt="16px"
        mb="16px"
        isLoadingText="Please Wait"
        onPress={goBack}
      >
        Try again
      </Button>
    </Flex>
  );
}

CrashScreen.propTypes = {
  goBack: PropTypes.func.isRequired,
};

export default CrashScreen;
