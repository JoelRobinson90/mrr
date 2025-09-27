/* eslint-disable react/forbid-prop-types */
import React, { useState } from 'react';
import {
  Button, Box, Flex, Alert, Text, useToast,
} from 'native-base';
import { StatusBar } from 'expo-status-bar';
import * as WebBrowser from 'expo-web-browser';
import useOktaAuth from '../../hooks/useOktaAuth';
import HomeLogo from '../../../assets/home-logo.svg';
import FullScreenLoading from '../../components/FullScreenLoading';
import useLoadingFonts from '../../hooks/useLoadingFonts';
import Sentry from '../../service/sentry';

function HomeScreen() {
  const [data, setData] = useState();

  const {
    triggerAuthentication, isLoading, loginAttemptFailed,
  } = useOktaAuth();
  const toast = useToast();

  const { fontsLoaded } = useLoadingFonts();

  if (!fontsLoaded) return null;

  return (
    <FullScreenLoading isLoading={isLoading} waitTime={450}>
      <Flex height="full" justify="space-between" align="center" px="16px" bg="#002D6C">
        <Box mt="239px">
          <Text
            pl="6px"
            fontSize="md"
            fontWeight="medium"
            color="white"
          >
            SDK 48 v.15
          </Text>
          <HomeLogo />
          <Text
            pl="6px"
            fontSize="md"
            fontWeight="medium"
            color="white"
          >
            {data}
          </Text>
        </Box>
        <Box w="full" mb="45px">
          {loginAttemptFailed && (
            <Alert status="error" colorScheme="error" mb={50}>
              <Flex
                direction="row"
                alignItems="center"
                justifyContent="flex-start"
                w="100%"
              >
                <Alert.Icon />
                <Text
                  pl="6px"
                  fontSize="md"
                  fontWeight="medium"
                  color="coolGray.800"
                >
                  Error authenticating please try again.
                </Text>
              </Flex>
            </Alert>
          )}
          <Button
            variant="primary"
            _text={{
              fontSize: 'primary',
            }}
            onPress={async () => {
              try {
                const re = await triggerAuthentication();
                setData(JSON.stringify(re));
              } catch (error) {
                Sentry?.Native?.captureException(error);
                toast.show({
                  description: 'Something went wrong, please contact support.',
                });
              }
            }}
          >
            Log in
          </Button>
          <Flex
            justifyContent="center"
            flexDirection="row"
            wrap="wrap"
            marginTop="5"
          >
            <Text
              pl="6px"
              fontSize="sm"
              color="white"
              textAlign="center"
            >
              By tapping Log in you agree to Medarrive&apos;s
              {' '}
            </Text>
            <Text
              onPress={() => WebBrowser.openBrowserAsync('https://www.medarrive.com/mobile-terms-of-service')}
              fontSize="sm"
              color="white"
              variant="link"
            >
              Terms & Conditions
            </Text>
            <Text
              pl="6px"
              fontSize="sm"
              color="white"
            >
              {' '}
              and
              {' '}
            </Text>
            <Text onPress={() => WebBrowser.openBrowserAsync('https://www.medarrive.com/privacy-policy')} fontSize="sm" color="white" variant="link">Privacy Policy</Text>
          </Flex>
        </Box>
        {/* eslint-disable-next-line react/style-prop-object */}
        <StatusBar style="light" />
      </Flex>
    </FullScreenLoading>
  );
}

export default HomeScreen;
