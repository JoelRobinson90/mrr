import React, { useState, useEffect, useMemo } from 'react';
import { Keyboard, TouchableWithoutFeedback } from 'react-native';
import PropTypes from 'proptypes';
import {
  Box,
  Select,
  CheckIcon,
  FormControl,
  TextArea,
  Button,
  useToast,
  WarningOutlineIcon,
  Flex,
  Text,
} from 'native-base';
import { useMutation, useQuery } from '@apollo/client';
import CANCEL_VISIT_MUTATION from '../../../graphql/mutations/visit/cancelVisit';
import GET_CANCEL_CODES_QUERY from '../../../graphql/queries/cancel_code/cancelCodes';
import Loading from '../../../components/Loading';
import GET_CURRENT_USER_QUERY from '../../../graphql/queries/user/currentUser';
import CustomBackButton from '../../../components/CustomBackButton';
import { sentryCaptureException } from '../../../service/sentry';
import startCase from '../../../helpers/startCase';
import useCheckValidAuth from '../../../hooks/useCheckValidAuth';

import ArrowDown from '../../../../assets/icons/fi_chevron_down.svg';

function CancelVisitScreen({ route, navigation }) {
  const visit = route?.params?.visit;
  const {
    loading: loadingUser,
    data: userData,
    error: userError,
  } = useQuery(GET_CURRENT_USER_QUERY);

  const currentUserData = userData?.getCurrentUser;

  const { data: cancelCodesData, loading: isLoadingCancelCodes } = useQuery(
    GET_CANCEL_CODES_QUERY,
  );
  const [selectedCancelCode, setSelectedCancelCode] = useState('');
  const [isMissingCancellation, setIsMissingCancellation] = useState(false);
  const [note, setNote] = useState('');

  const toast = useToast();

  const [
    cancelVisitMutation,
    { loading: isCancelingVisit, error: cancelVisitError },
  ] = useMutation(CANCEL_VISIT_MUTATION);

  const error = userError || cancelVisitError;
  useCheckValidAuth(error);

  const onCancelVisit = async () => {
    if (!selectedCancelCode) {
      setIsMissingCancellation(true);
      return;
    }
    setIsMissingCancellation(false);
    try {
      await cancelVisitMutation({
        variables: {
          id: parseInt(visit.id, 10),
          cancel_code_id: parseInt(selectedCancelCode, 10),
          note,
        },
      });
      navigation.navigate('Visit', {
        visit,
      });
    } catch (requestError) {
      sentryCaptureException(cancelVisitError, currentUserData);
      sentryCaptureException(requestError, currentUserData);
      toast.show({
        description: 'Something went wrong please try again',
      });
    }
  };

  useEffect(() => {
    navigation.setOptions({
      title: '',
      headerLeft: CustomBackButton,
      headerShadowVisible: false,
    });
  }, [navigation]);

  const cancelDescription = useMemo(() => {
    const { getCancelCodes } = cancelCodesData || {};
    return getCancelCodes?.find((cancel) => cancel.id === selectedCancelCode)?.description;
  }, [selectedCancelCode]);

  if (loadingUser || isLoadingCancelCodes) {
    return (
      <Box height="80%" justifyContent="center">
        <Loading message="Loading please wait ..." />
      </Box>
    );
  }

  return (
    <TouchableWithoutFeedback onPress={() => Keyboard.dismiss()}>
      <Box bg="white" px="20px" pt="10px" h="full">
        <Flex justifyContent="space-between" flexGrow="1">
          <Flex>
            <FormControl isInvalid={isMissingCancellation} mb="32px">
              <FormControl.Label>
                <Text variant="label">Cancellation Reason</Text>
              </FormControl.Label>
              <Select
                h="37px"
                selectedValue={selectedCancelCode}
                accessibilityLabel="Select"
                placeholder="Select"
                _selectedItem={{
                  startIcon: <CheckIcon size="5" />,
                }}
                mt="4px"
                onValueChange={(itemValue) => setSelectedCancelCode(itemValue)}
                InputRightElement={(
                  <Box mr="12px">
                    <ArrowDown />
                  </Box>
                )}
              >
                {cancelCodesData?.getCancelCodes?.map((cancelCode) => (
                  <Select.Item
                    key={cancelCode.id}
                    label={startCase(cancelCode.code)}
                    value={cancelCode.id}
                  />
                ))}
              </Select>
              <FormControl.ErrorMessage
                leftIcon={<WarningOutlineIcon size="xs" />}
              >
                Please select a cancel reason.
              </FormControl.ErrorMessage>
            </FormControl>

            {cancelDescription
            && (
            <>
              <Text variant="label">Description</Text>
              <Text variant="note" mt="8px" mb="24px">
                {cancelDescription}
              </Text>
            </>
            )}

            <FormControl>
              <FormControl.Label mb="16px">
                <Text variant="title" fontSize="main">
                  Add Note (Optional)
                </Text>
              </FormControl.Label>
              <TextArea
                variant="noteCard"
                onChangeText={(text) => {
                  setNote(text);
                }}
                value={note}
                placeholder="Write a note"
              />
            </FormControl>
          </Flex>

          <Flex flexDirection="row" mb="30px" justify="space-between">
            <Button
              w="25%"
              variant="main"
              outline
              onPress={() => navigation.goBack()}
            >
              Cancel
            </Button>
            <Button
              w="50%"
              variant="main"
              spinnerPlacement="end"
              isLoading={isCancelingVisit}
              isLoadingText="Please wait"
              onPress={onCancelVisit}
              isDisabled={!selectedCancelCode}
            >
              Confirm Cancellation
            </Button>
          </Flex>
        </Flex>
      </Box>
    </TouchableWithoutFeedback>
  );
}

CancelVisitScreen.propTypes = {
  route: PropTypes.object.isRequired,
  navigation: PropTypes.object.isRequired,
};

export default CancelVisitScreen;
