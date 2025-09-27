/* eslint-disable import/order */
import React, { useContext, useState } from 'react';
import PropTypes from 'proptypes';
import { Platform } from 'react-native';
import * as WebBrowser from 'expo-web-browser';
import Constants from 'expo-constants';
import { Button, Text, Flex } from 'native-base';
import { AuthContext } from '../../context/auth';
import { clearTokens } from '../../hooks/useOktaAuth';
import { useApolloClient } from '@apollo/client';
import { httpLink } from '../../graphql/client';
import FullScreenLoading from '../../components/FullScreenLoading';

const { oktaClientId, oktaUrl } = Constants.expoConfig.extra;

function ProfileScreen({ navigation }) {
  const [currentUser, setCurrentUser] = useContext(AuthContext);
  const client = useApolloClient();
  const [isLoading, setIsLoading] = useState(false);

  const { displayName, email } = currentUser || {};

  return (
    <Flex align="center">
      <FullScreenLoading isLoading={isLoading}>
        <Text mt="80px" variant="title" color="muted.600" fontSize="main">
          {displayName}
        </Text>
        <Text mt="16px" variant="note" fontSize="main" w="232px" textAlign="center">
          {email}
        </Text>
        <Button
          mt="216"
          p="0"
          variant="main"
          w="126px"
          _text={{
            fontSize: 'text',
          }}
          onPress={async () => {
            // This logic was causing a weird redirect issue on iOS hence
            // the need of only triggering for Android.
            if (Platform.OS === 'android') {
              // hitting Okta logout endpoint so it actually closes session on mobile web browser.
              WebBrowser.openBrowserAsync(`${oktaUrl}/oauth2/default/v1/logout?id_token_hint=${currentUser.idToken}&client_id=${oktaClientId}&post_logout_redirect_uri=medarriveapp://Home`);
            }

            setIsLoading(true);
            // empty currentUser from context.
            setCurrentUser(null);
            // clears authorization token on GraphQL.
            client.setLink(httpLink);
            // clears refresh token from storage.
            await clearTokens();
            // wait to stop the UI at home making the call to fetch too fast before emptying data.
            setTimeout(() => navigation.navigate('Home'), 2000);
          }}
        >
          Log out
        </Button>
      </FullScreenLoading>
    </Flex>
  );
}

ProfileScreen.propTypes = {
  navigation: PropTypes.shape({
    navigate: PropTypes.func.isRequired,
  }).isRequired,
};

export default ProfileScreen;
