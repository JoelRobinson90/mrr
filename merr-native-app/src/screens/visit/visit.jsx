/* eslint-disable jsx-a11y/anchor-is-valid */
import React, { useState, useCallback, useMemo } from 'react';
import { Platform } from 'react-native';
import PropTypes from 'proptypes';
import {
  Alert,
  Button,
  Box,
  Text,
  Flex,
  Badge,
  Link,
  ScrollView,
  useToast,
  Pressable,
  Icon,
  useClipboard,
} from 'native-base';
import * as WebBrowser from 'expo-web-browser';
import * as Location from 'expo-location';
import { useMutation, useQuery } from '@apollo/client';
import { useFocusEffect } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import calculateAge from '../../helpers/calculateAge';
import PatientModal from '../../components/PatientModal';
import CREATE_VISIT_EVENT_MUTATION from '../../graphql/mutations/visit_event/createVisitEvent';
import standardizeStatus from '../../helpers/displayStatus';
import ActionButton from '../../components/ActionButton';
import GET_CURRENT_USER_QUERY from '../../graphql/queries/user/currentUser';
import GET_VISIT_QUERY from '../../graphql/queries/visits/getVisit';
import useCheckValidAuth from '../../hooks/useCheckValidAuth';
import useDeviceType from '../../hooks/useDeviceType';
import getRecentVisitEvent from '../../helpers/visitEvents';
import formatVisitProviders from '../../helpers/formatVisitProviders';
import openExternalUrl from '../../helpers/openExternalUrl';
import getDateWithTimeZone from '../../helpers/getDateWithTimeZone';
import calculateDuration from '../../helpers/calculateDuration';
import { sentryCaptureException } from '../../service/sentry';

function VisitScreen({ route, navigation }) {
  const { isMobile } = useDeviceType();
  const toast = useToast();
  const {
    // loading: loadingUser,
    error: errorDataUser,
    data: userData,
  } = useQuery(GET_CURRENT_USER_QUERY);

  const currentUserData = userData?.getCurrentUser;

  const { onCopy } = useClipboard();

  const [isButtonLoading, setIsButtonLoading] = useState(false);
  const [createVisitEvent, { loading: loadingCreatingVisitEvent }] =
    useMutation(CREATE_VISIT_EVENT_MUTATION);

  const [patientModalVisible, setPatientModalVisible] = useState(false);
  const [visit, setVisit] = useState(route?.params?.visit || {});
  const { patient } = visit || {};
  const { address } = patient || {};
  const providers = useMemo(
    () => formatVisitProviders(visit.providers),
    [visit],
  );
  const { actionsAllowed = true } = route?.params;

  const addressLineOneWithoutNumber = address.address_line_one
    .split(' ')
    .slice(1)
    .join(' ');

  const {
    // loading: loadingVisit,
    error: errorVisitData,
    // data: visitData,
    refetch,
  } = useQuery(GET_VISIT_QUERY, {
    variables: {
      id: visit?.id,
    },
    onCompleted: (res) => setVisit(res.getVisit),
  });

  const checkError = errorVisitData || errorDataUser;
  useCheckValidAuth(checkError);

  const destination = encodeURIComponent(
    `${address?.address_line_one} ${address?.city}, ${address?.state} ${address?.zipcode}`,
  );

  const provider = Platform.OS === 'ios' ? 'apple' : 'google';
  const link = `http://maps.${provider}.com/?daddr=${destination}`;

  const currentEvent = getRecentVisitEvent(visit);

  useFocusEffect(
    useCallback(() => {
      setIsButtonLoading(false);
      if (currentUserData?.id) {
        refetch();
      }
    }, [visit?.id, currentUserData?.id]),
  );

  const postVisitEvent = async (type) => {
    const location = await Location.getCurrentPositionAsync({});
    if (currentUserData?.id) {
      await createVisitEvent({
        variables: {
          time: new Date(),
          location: `${location?.coords?.latitude}, ${location?.coords?.longitude}`,
          field_provider_id: parseInt(currentUserData?.account?.id, 10),
          visit_id: parseInt(visit?.id, 10),
          event_type: type,
        },
      });
    } else {
      toast.show({
        description: 'Something went wrong: user was not set correctly',
      });
    }
  };

  const enterVisitFlow = async () => {
    setIsButtonLoading(true);
    switch (currentEvent?.event_type) {
      case 'on_site':
        navigation.navigate('Summary', {
          visit,
          currentEvent,
        });
        return;
      case 'clocked_in':
        navigation.navigate('Summary', {
          visit,
          currentEvent,
        });
        return;
      case 'en_route':
        navigation.navigate('Preview', {
          visit,
          preview: false,
        });
        return;
      default:
        try {
          await postVisitEvent('en_route');
          navigation.navigate('Preview', { visit, preview: false });
        } catch (error) {
          sentryCaptureException(error, currentUserData);
          toast.show({
            description:
              'Something went wrong when trying to update this visit to En Route, please try again.',
          });
          setIsButtonLoading(false);
        }
    }
  };

  const isCompleted =
    currentEvent?.event_type === 'complete' && !visit?.canceled;
  const status =
    visit?.confirmed && visit?.status === 'scheduled'
      ? 'confirmed'
      : visit?.status;

  const actionsLists = [
    {
      id: 1,
      label: 'Reschedule Visit',
      hidden: true,
      icon: 'reschedule',
      action: () => {},
    },
    {
      id: 2,
      label: 'Cancel Visit',
      hidden: visit?.canceled,
      icon: 'cancel',
      action: () => {
        navigation.navigate('CancelVisit', {
          visit,
        });
      },
    },
    {
      id: 3,
      label: 'Report Problem',
      hidden: true,
      icon: 'report',
      action: () => {},
    },
  ];

  const duration = visit?.start_time && visit?.end_time
    ? calculateDuration(visit?.start_time, visit?.end_time) : 0;

  return (
    <>
      <ScrollView>
        {!actionsAllowed && !visit?.canceled && (
          <Alert status="error" colorScheme="error">
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
                Previous visits need to be cancelled or completed to unlock this
                visit
              </Text>
            </Flex>
          </Alert>
        )}
        {visit?.canceled && (
          <Alert status="info" colorScheme="info">
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
                Visit has been cancelled
              </Text>
            </Flex>
          </Alert>
        )}
        {isCompleted && (
          <Alert status="success" colorScheme="success">
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
                Visit Completed
              </Text>
            </Flex>
          </Alert>
        )}
        <PatientModal
          modalVisible={patientModalVisible}
          setModalVisible={() => setPatientModalVisible(false)}
          visit={visit}
          actionsAllowed={actionsAllowed}
        />
        <Box px="16px" py="24px" bg="white">
          <Flex mb="16px" direction="row" justifyContent="space-between">
            <Text bold>Visit #{visit?.id}</Text>
            <Badge rounded="lg" colorScheme={status}>
              <Text variant="badge" fontSize="note" colorScheme={status}>
                {standardizeStatus(isCompleted ? 'completed' : status)}
              </Text>
            </Badge>
          </Flex>
          <Flex direction="row" justifyContent="space-between" mb="16px">
            <Text variant="text" fontSize="main">
              {getDateWithTimeZone(
                visit?.cx_start,
                'ddd, MMMM DD',
                visit?.patient?.address?.timezone,
              )}
            </Text>
            <Text variant="text" fontSize="main">
              {getDateWithTimeZone(
                visit?.cx_start,
                'h:mm a',
                visit?.patient?.address?.timezone,
              )}{' '}
              -{' '}
              {getDateWithTimeZone(
                visit?.cx_end,
                'h:mm a',
                visit?.patient?.address?.timezone,
              )}
            </Text>
          </Flex>
          <Flex direction="row" mb="16px">
            <Text variant="text" fontSize="main">
              Arrival Window:
              {' '}
            </Text>
            <Text variant="text" fontSize="main">
              {getDateWithTimeZone(visit?.arrival_window_start, 'h:mm a', visit?.patient?.address?.timezone)}
              {' '}
              -
              {' '}
              {getDateWithTimeZone(visit?.arrival_window_end, 'h:mm a', visit?.patient?.address?.timezone)}
            </Text>
          </Flex>
          {duration
            ? (
              <Flex direction="row" mb="16px">
                <Text variant="text" fontSize="main">
                  Duration:
                  {' '}
                </Text>
                <Text variant="text" fontSize="main">
                  {duration}
                  {' '}
                  minutes
                </Text>
              </Flex>
            ) : null}
          <Box>
            <Text mb="16px" variant="text" fontSize="main">
              {actionsAllowed
                ? address?.address_line_one
                : addressLineOneWithoutNumber}
              {` ${address?.address_line_two || ''} ${address?.city} ${
                address?.state
              } ${address?.zipcode}`}
            </Text>
            {actionsAllowed && (
              <Box>
                <Link href={link}>
                  <Text variant="link" fontWeight="500" fontSize="main">
                    Open Navigation
                  </Text>
                </Link>
              </Box>
            )}
          </Box>
        </Box>
        <Box h="4px" bg="muted.300" />
        <Box px="16px" py="24px" bg="white">
          <Text variant="title" fontSize="main">
            About Patient
          </Text>
          <Flex direction="row" justifyContent="space-between" my="16px">
            <Text variant="text" fontSize="main" fontWeight="500">
              {`${patient?.first_name} ${patient?.last_name}`}
            </Text>
            <Text variant="text" fontSize="main">
              {calculateAge(patient?.date_of_birth)} years old
            </Text>
          </Flex>
          <Text variant="text" fontSize="main">
            Preferred Language: {patient?.preferred_language}
          </Text>
          <Pressable my="16px" onPress={() => setPatientModalVisible(true)}>
            <Text variant="link" fontWeight="500" fontSize="main">
              Show Profile
            </Text>
          </Pressable>
          {patient.phone_number && (
            <Flex direction="row" style={{ width: '60%' }}>
              {isMobile && (
                <Flex mr="12px">
                  <Button
                    p="0"
                    variant="main"
                    h="31px"
                    w="96px"
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
                </Flex>
              )}
              <Flex>
                <Button
                  p="0"
                  variant="main"
                  h="31px"
                  w="96px"
                  outline
                  _text={{
                    fontSize: 'note',
                  }}
                  onPress={() =>
                    openExternalUrl('sms:', visit?.patient?.phone_number)
                  }
                >
                  Message
                </Button>
              </Flex>
            </Flex>
          )}
        </Box>
        <Box h="4px" bg="muted.300" />
        <Box px="16px" py="24px" bg="white">
          <Text variant="title" fontSize="main">
            Visit Type
          </Text>
          <Text my="16px" variant="text" fontSize="main" fontWeight="500">
            {visit?.visit_type?.name || 'No Associated Program'}
          </Text>
          <Text variant="title" fontSize="main" mb="16px">
            Services
          </Text>
          <Box>
            {visit?.services?.length > 0
              ? visit?.services?.map((service) => (
                  <Box key={service?.name}>
                    <Text variant="text" fontSize="main">
                      {service?.name}
                    </Text>
                  </Box>
                ))
              : 'No Associated Services'}
          </Box>
          {providers?.map(({ name, label }) => (
            <Box key={name}>
              <Text variant="title" fontSize="main" my="16px">
                {label}
              </Text>
              <Text variant="text" fontSize="main">
                {name}
              </Text>
            </Box>
          ))}
          {visit?.athenaTelehealthUrl && (
            <Flex
              py="20px"
              bg="white"
              flexDirection="row"
              alignItems="baseline"
            >
              <Text
                onPress={() =>
                  WebBrowser.openBrowserAsync(visit?.athenaTelehealthUrl)
                }
                fontSize="sm"
                variant="link"
                color="cyan.500"
              >
                Athena Telehealth Link
              </Text>
              <Icon
                size="lg"
                ml="10px"
                onPress={() => {
                  onCopy(visit?.athenaTelehealthUrl);
                  toast.show({
                    description: 'Athena Telelealth link copied!',
                  });
                }}
                as={Ionicons}
                color="cyan.500"
                name="ios-copy-outline"
              />
            </Flex>
          )}
          <Text variant="title" fontSize="main" my="16px">
            Service Instructions
          </Text>
          <Text variant="text" fontSize="main">
            {visit?.service_instructions || 'No Service Instructions'}
          </Text>
        </Box>
        <Box h="4px" bg="muted.300" />
        <Box pb="24px" bg="white">
          <Box p="16px">
            <ActionButton
              iconName="book"
              label="Visit Notes"
              count={visit?.admin_notes?.length}
              onPress={() => {
                navigation.navigate('Notes', { visit });
              }}
            />
          </Box>
          <Box h="4px" bg="muted.300" />
          <Box px="16px">
            <Text mt="24px" variant="title" fontSize="text">
              Actions
            </Text>
            {actionsLists.map(({ id, label, hidden, icon, action }) => {
              if (hidden) return null;
              return (
                <ActionButton
                  key={id}
                  iconName={icon}
                  label={label}
                  onPress={action}
                />
              );
            })}
          </Box>
        </Box>
      </ScrollView>
      {!isCompleted && !visit?.canceled && (
        <Flex pt="20px" pb="40px" align="center" bg="white" px="16px">
          <Button
            isDisabled={!actionsAllowed}
            variant={'main'}
            testID="enRouteButton"
            w="full"
            isLoading={loadingCreatingVisitEvent || isButtonLoading}
            isLoadingText="Please Wait"
            onPress={enterVisitFlow}
          >
            {!currentEvent ? 'En Route' : 'Continue'}
          </Button>
        </Flex>
      )}
    </>
  );
}

VisitScreen.propTypes = {
  route: PropTypes.object.isRequired,
  navigation: PropTypes.object.isRequired,
};

export default VisitScreen;
