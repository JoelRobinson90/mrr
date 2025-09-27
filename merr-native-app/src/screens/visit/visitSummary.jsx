import React, { useCallback, useState } from 'react';
import PropTypes from 'proptypes';
import {
  Box,
  Text,
  ScrollView,
  Button,
  Badge,
  Flex,
  useToast,
  CloseIcon,
  Pressable,
} from 'native-base';
import { useMutation, useQuery } from '@apollo/client';
import { useFocusEffect } from '@react-navigation/native';
import PatientDetails from '../../components/PatientDetails';
import standardizeStatus from '../../helpers/displayStatus';
import GET_CURRENT_USER_QUERY from '../../graphql/queries/user/currentUser';
import CREATE_VISIT_EVENT_MUTATION from '../../graphql/mutations/visit_event/createVisitEvent';
import GET_VISIT_QUERY from '../../graphql/queries/visits/getVisit';
import useCheckValidAuth from '../../hooks/useCheckValidAuth';
import DotMenu from '../../components/DotMenu';
import { sentryCaptureException } from '../../service/sentry';
import useGeolocation from '../../hooks/useGeolocation';
import useDeviceType from '../../hooks/useDeviceType';
import getRecentVisitEvent from '../../helpers/visitEvents';
import openExternalUrl from '../../helpers/openExternalUrl';

function VisitSummaryScreen({ route, navigation }) {
  const { isMobile } = useDeviceType();
  const toast = useToast();
  const [createVisitEvent, { loading: loadingCreatingVisitEvent }] =
    useMutation(CREATE_VISIT_EVENT_MUTATION);
  const { location } = useGeolocation();
  const {
    // loading: loadingUser,
    error: errorDataUser,
    data: userData,
  } = useQuery(GET_CURRENT_USER_QUERY);

  const currentUserData = userData?.getCurrentUser;
  const [, setVisit] = useState(null);

  const {
    loading: loadingVisit,
    error: errorVisitData,
    data: { getVisit },
    refetch,
  } = useQuery(GET_VISIT_QUERY, {
    variables: {
      id: route?.params?.visit?.id,
    },
  });

  const { patient } = getVisit || {};

  const checkError = errorDataUser || errorVisitData;
  useCheckValidAuth(checkError);

  useFocusEffect(
    useCallback(() => {
      if (currentUserData?.id) {
        refetch();
      }
    }, [currentUserData?.id]),
  );

  const postVisitEvent = async (type) => {
    try {
      if (!currentUserData?.id) {
        throw new Error('No user data found, please authenticate again.');
      }
      await createVisitEvent({
        variables: {
          time: new Date(),
          location: `${location?.coords?.latitude}, ${location?.coords?.longitude}`,
          field_provider_id: parseInt(currentUserData?.account?.id, 10),
          visit_id: parseInt(getVisit?.id, 10),
          event_type: type,
        },
      });
    } catch (error) {
      sentryCaptureException(error, currentUserData);
      toast.show({
        description: `Error on visitSummary: postVisitEvent: ${error}`,
      });
    }
  };

  const advanceVisitFlow = async (event) => {
    await postVisitEvent(event);
    await refetch();
    setVisit(getVisit);
  };

  const currentEvent = getRecentVisitEvent(getVisit);
  const status = standardizeStatus(getVisit?.status);

  return (
    <Box bg="00000066">
      <Box variant="modal" mt="40px" h="100%" bg="white">
        <Box borderBottomColor="#E5E5E5" borderBottomWidth={1} pb="8px">
          <Flex
            direction="row"
            justifyContent="space-between"
            align="center"
            pt="36px"
            px="20px"
            pb="42px"
          >
            <Pressable
              onPress={() => {
                if (getVisit?.status === 'completed') {
                  navigation.navigate('Dashboard');
                } else {
                  navigation.navigate('Visit', {
                    getVisit,
                  });
                }
              }}
            >
              <CloseIcon size="4" color="muted.700" />
            </Pressable>
            <Box>
              <DotMenu visit={getVisit || {}} />
            </Box>
          </Flex>
          <Flex
            px="16px"
            direction="row"
            justifyContent="space-between"
            alignItems="center"
          >
            <Text bold>
              Visit #
              {' '}
              {getVisit?.id}
            </Text>
            <Badge rounded="lg" colorScheme={getVisit?.status}>
              {status || 'No status'}
            </Badge>
          </Flex>
        </Box>
        <ScrollView mt={0}>
          {getVisit?.visit_events
            && currentEvent?.event_type
              !== 'on_site' && (
              <>
                <Box px="16px" pt="34px">
                  <Text pb="8px" bold>
                    Visit Type
                  </Text>
                  <Text py="8px">{getVisit?.visit_type.name}</Text>
                  <Text py="8px" bold>
                    Services
                  </Text>
                  <Box py="8px">
                    {getVisit?.services.map((service) => (
                      <Text key={service.name} pt="4px">
                        {service.name}
                      </Text>
                    ))}
                  </Box>
                </Box>
                <Box py="2px" bg="muted.300" />
              </>
          )}
          <Box px="16px" pt="24px">
            <Text pb="16px" bold>
              {patient?.first_name}
              {' '}
              {patient?.last_name}
            </Text>
            <PatientDetails visit={getVisit || {}} />
            {isMobile && (
            <Button
              w="99px"
              h="31px"
              p="0"
              variant="main"
              outline
              _text={{
                fontSize: 'note',
              }}
              onPress={async () => {
                openExternalUrl('tel://', patient?.phone_number);
              }}
            >
              Call
            </Button>
            )}
            <Text variant="note" mt="16px">
              Phone Number:
              {' '}
              {patient?.phone_number}
            </Text>
          </Box>
        </ScrollView>

        {getVisit?.status !== 'completed' && (
          <Box>
            <Flex direction="row" justifyContent="center" pb="100px">
              {getVisit?.visit_events
              && currentEvent
                ?.event_type === 'clocked_in' ? (
                  <Button
                    width="90%"
                    mt="16px"
                    mb="16px"
                    isLoading={loadingCreatingVisitEvent || loadingVisit}
                    isLoadingText="Please Wait"
                    onPress={() => advanceVisitFlow('complete')}
                  >
                    Finish Visit
                  </Button>
                ) : (
                  <Button
                    width="90%"
                    mt="16px"
                    mb="16px"
                    isLoading={loadingCreatingVisitEvent || loadingVisit}
                    isLoadingText="Please Wait"
                    onPress={() => advanceVisitFlow('clocked_in')}
                  >
                    Start Visit
                  </Button>
                )}
            </Flex>
          </Box>
        )}
      </Box>
    </Box>
  );
}

VisitSummaryScreen.propTypes = {
  route: PropTypes.object.isRequired,
  navigation: PropTypes.object.isRequired,
};

export default VisitSummaryScreen;
