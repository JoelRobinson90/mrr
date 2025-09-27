/* eslint-disable react/forbid-prop-types */
import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { StatusBar } from 'expo-status-bar';
import { Text, Button, Flex, useToast } from 'native-base';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { useMutation, useQuery } from '@apollo/client';
import { Platform, Linking } from 'react-native';
import GET_CURRENT_USER_QUERY from '../../graphql/queries/user/currentUser';
import CREATE_VISIT_EVENT_MUTATION from '../../graphql/mutations/visit_event/createVisitEvent';
import GET_VISIT_QUERY from '../../graphql/queries/visits/getVisit';
import { sentryCaptureException } from '../../service/sentry';
import useCheckValidAuth from '../../hooks/useCheckValidAuth';

import useGeolocation from '../../hooks/useGeolocation';
import DotMenu from '../../components/DotMenu';

export default function Preview({ route, navigation }) {
  const routeParams = { ...route?.params };
  const { visit, preview, showStreetNumber = true } = routeParams;
  const patientAddress = { ...visit?.patient?.address };
  const { latitude, longitude } = patientAddress;
  const patientData = { ...visit?.patient };
  const { address } = patientData;
  const { location } = useGeolocation();
  const [createVisitEvent, { loading: loadingCreatingVisitEvent }] =
    useMutation(CREATE_VISIT_EVENT_MUTATION);

  const addressLineOneWithoutNumber = patientAddress?.address_line_one
    ?.split(' ')
    .slice(1)
    .join(' ');

  const toast = useToast();

  const {
    // loading: loadingVisit,
    error: errorVisitData,
    data: visitData,
    refetch,
  } = useQuery(GET_VISIT_QUERY, {
    variables: {
      id: route?.params?.visit?.id,
    },
  });

  const {
    // loading: loadingUser,
    error: errorDataUser,
    data: userData,
  } = useQuery(GET_CURRENT_USER_QUERY);

  const error = errorVisitData || errorDataUser;
  useCheckValidAuth(error);

  const currentUserData = userData?.getCurrentUser;

  const postVisitEvent = async (type) => {
    try {
      if (!currentUserData?.id) {
        throw new Error('No user data found, please authenticate again.');
      }
      createVisitEvent({
        variables: {
          time: new Date(),
          location: `${location?.coords?.latitude}, ${location?.coords?.longitude}`,
          field_provider_id: parseInt(currentUserData?.account?.id, 10),
          visit_id: parseInt(visit?.id, 10),
          event_type: type,
        },
      });
    } catch (_error) {
      sentryCaptureException(_error, currentUserData);
      toast.show({
        description: `Error on Preview:postVisitEvent: ${_error}`,
      });
    }
  };

  const destination = encodeURIComponent(
    `${address?.address_line_one} ${address?.city}, ${address?.state} ${address?.zipcode}`,
  );
  const provider = Platform.OS === 'ios' ? 'apple' : 'google';
  const link = `http://maps.${provider}.com/?daddr=${destination}`;

  const advanceVisitFlow = async () => {
    await postVisitEvent('on_site');
    await refetch();

    navigation.navigate('Summary', {
      visit: visitData.getVisit,
    });
  };

  const headerRight = () => preview === false && <DotMenu visit={visit} bg />;

  useEffect(() => {
    navigation.setOptions({
      headerRight,
    });
  }, [preview, navigation]);

  let mapProvider = {
    provider: PROVIDER_GOOGLE,
  };

  if (Platform.OS === 'ios') {
    mapProvider = {};
  }

  return (
    <Flex pb="16px" flex="1" align="center" bg="white">
      <MapView
        // eslint-disable-next-line react/jsx-props-no-spreading
        {...mapProvider}
        style={{ flex: 1, width: '100%', height: '100%' }}
        initialRegion={{
          latitude: parseFloat(latitude),
          longitude: parseFloat(longitude),
          latitudeDelta: 0.0922,
          longitudeDelta: 0.0421,
        }}
      >
        <Marker
          key={`${latitude},${longitude}`}
          coordinate={{
            latitude: parseFloat(latitude),
            longitude: parseFloat(longitude),
          }}
          title="patient address"
        />
      </MapView>
      <Flex pt="8px" pb="24px" variant="drawer" align="center" mt="-25px">
        <Flex
          width="100%"
          direction="row"
          pt="14px"
          px="24px"
          justifyContent={preview === false ? 'space-between' : 'center'}
          align="center"
        >
          {preview === false && showStreetNumber && (
            <Button
              variant="main"
              outline
              h="45px"
              w="47%"
              _text={{
                fontSize: 'text',
              }}
              onPress={async () => {
                await Linking.openURL(link);
              }}
            >
              Start Navigation
            </Button>
          )}
          <Flex
            justifyContent="center"
            wrap="wrap"
            w={preview === false ? '47%' : 'full'}
          >
            <Text
              variant="text"
              fontSize="text"
              w="full"
              textAlign={preview === false ? 'left' : 'center'}
            >
              {showStreetNumber
                ? visit?.patient?.address?.address_line_one
                : addressLineOneWithoutNumber}
            </Text>
          </Flex>
        </Flex>
        {preview === false && (
          <Button
            testID="arrivedButton"
            isLoading={loadingCreatingVisitEvent}
            isLoadingText="Please wait"
            width="87%"
            mt="32px"
            h="50px"
            onPress={advanceVisitFlow}
            variant="main"
            _text={{
              fontSize: 'main',
            }}
            isDisabled={false}
          >
            I&apos;ve Arrived
          </Button>
        )}
      </Flex>
      {/* eslint-disable-next-line react/style-prop-object */}
      <StatusBar style="dark" />
    </Flex>
  );
}

Preview.propTypes = {
  route: PropTypes.object.isRequired,
  navigation: PropTypes.object.isRequired,
};
